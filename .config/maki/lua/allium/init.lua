-- Allium integration for maki (self-contained package).
--
-- Allium (https://github.com/juxt/allium) ships as plain-Markdown "skills"
-- plus an optional CLI (`allium check`). Maki has no native skill loader, so
-- this plugin adapts allium to maki primitives. Everything it needs lives
-- under this directory:
--
--   lua/allium/
--     init.lua           this module (require("allium") loads it)
--     skills/<name>/     bundled SKILL.md + references for each skill
--
-- It provides:
--   * slash commands (/allium, /elicit, ...) that inject the matching
--     SKILL.md as a prompt so the model runs that workflow
--   * a prompt hint so the model knows the skills exist and auto-triggers on
--     .allium edits
--   * a ToolDone autocmd that runs `allium check` after write/edit tools and
--     feeds diagnostics back (no-op until the CLI is on PATH)

-- Locate the bundled skills relative to maki's config dir. require() is
-- sandboxed to lua/, but fs is not, so we build the absolute path ourselves.
local SKILLS_DIR = maki.fs.joinpath(maki.env.config_dir(), "lua", "allium", "skills")

-- name -> one-line description shown in the command palette
local SKILLS = {
   allium = "Entry point: route to the right skill, or drive the whole loop.",
   elicit = "Build an Allium spec through structured conversation.",
   distill = "Extract an Allium spec from existing code.",
   propagate = "Generate tests from an Allium spec.",
   tend = "Make targeted edits to an existing Allium spec.",
   weed = "Find and reconcile spec-vs-code divergences.",
   witness = "Independently attest a loop's convergence claim.",
}

local function skill_path(name)
   return maki.fs.joinpath(SKILLS_DIR, name, "SKILL.md")
end

local function load_skill(name)
   local text, err = maki.fs.read(skill_path(name))
   if not text then
      return nil, err
   end
   return text
end

-- Register a slash command per skill. The handler reads SKILL.md and sends it,
-- with any user args, as a prompt for the model to act on.
for name, desc in pairs(SKILLS) do
   maki.api.register_command {
      name = "/" .. name,
      description = "Allium: " .. desc,
      nargs = "*",
      handler = function(opts)
         local skill, err = load_skill(name)
         if not skill then
            maki.ui.flash("allium: could not read " .. name .. " skill: " .. tostring(err))
            return
         end

         local parts = {
            "You are running the Allium `" .. name .. "` skill. Follow its",
            "instructions below. Reference files it links to live under",
            maki.fs.joinpath(SKILLS_DIR, name) .. " and the shared",
            maki.fs.joinpath(SKILLS_DIR, "allium", "references") .. " directory;",
            "read them with the read tool as the skill directs.",
            "",
         }
         local args = opts.args and opts.args:gsub("^%s+", ""):gsub("%s+$", "") or ""
         if args ~= "" then
            parts[#parts + 1] = "User request: " .. args
            parts[#parts + 1] = ""
         end
         parts[#parts + 1] = "--- SKILL.md ---"
         parts[#parts + 1] = skill

         local _, perr = maki.session.prompt(table.concat(parts, "\n"))
         if perr then
            maki.ui.flash("allium: could not start prompt: " .. tostring(perr))
         end
      end,
   }
end

-- Expose the bundled skills as a single tool, mirroring maki's native `skill`
-- tool. The body of each skill stays out of context until the model calls this
-- with a name. Everything ships inside the plugin, so there are no filesystem
-- side effects to leak on removal.
local SKILL_ORDER = { "allium", "elicit", "distill", "propagate", "tend", "weed", "witness" }

local function skill_tool_description()
   local lines = {
      "Load an Allium skill: a Markdown workflow for behavioural specs.",
      "Allium (juxt/allium) captures what software should do, separate from how.",
      "Call this with a skill name to get that workflow's full instructions, then follow them.",
      "Also read a skill when the user edits a `.allium` file or asks to build, extract, edit,",
      "or generate tests from a behavioural spec.",
      "",
      "Available skills:",
   }
   for _, name in ipairs(SKILL_ORDER) do
      lines[#lines + 1] = "- " .. name .. ": " .. SKILLS[name]
   end
   return table.concat(lines, "\n")
end

maki.api.register_tool {
   name = "allium_skill",
   kind = "read",
   description = skill_tool_description(),
   schema = {
      type = "object",
      properties = {
         name = {
            type = "string",
            enum = SKILL_ORDER,
            description = "Which Allium skill to load.",
         },
      },
      required = { "name" },
   },
   handler = function(input)
      local name = input and input.name
      if not name or not SKILLS[name] then
         return {
            llm_output = "error: unknown skill '" .. tostring(name) .. "'. Valid: " .. table.concat(SKILL_ORDER, ", "),
            is_error = true,
         }
      end

      local skill, err = load_skill(name)
      if not skill then
         return { llm_output = "error: could not read " .. name .. " skill: " .. tostring(err), is_error = true }
      end

      local preamble = table.concat({
         "Allium `" .. name .. "` skill. Follow these instructions.",
         "Reference files it links to live under " .. maki.fs.joinpath(SKILLS_DIR, name),
         "and the shared " .. maki.fs.joinpath(SKILLS_DIR, "allium", "references") .. " directory;",
         "read them with the read tool as the skill directs.",
         "",
         "--- SKILL.md ---",
         "",
      }, "\n")

      return { llm_output = preamble .. skill, format = "markdown" }
   end,
}

-- Tell the model the skills exist so it can auto-trigger on .allium files
-- even without an explicit slash command.
maki.api.register_prompt_hint {
   slot = "conventions",
   content = function()
      return table.concat({
         "Allium skills are bundled in this plugin and exposed via the",
         "`allium_skill` tool (names: allium, elicit, distill, propagate, tend,",
         "weed, witness). When the user works with `.allium` spec files, or asks",
         "to build/extract/edit a behavioural spec or generate tests from one,",
         "call `allium_skill` with the relevant name and follow it. The user can",
         "also invoke them as /allium, /elicit, /distill, /propagate, /tend,",
         "/weed, /witness.",
      }, "\n")
   end,
}

-- Verification: run `allium check` after an edit, but only when the edit
-- actually touched a `.allium` file.
--
-- The ToolDone event carries no path, so we learn the path upstream: maki
-- fires a `tool.<name>.input` slot before each write tool runs, and that value
-- holds the path. We wrap those slots to record, per tool call, whether an
-- .allium file was touched; the ToolDone handler then checks that record.
local WRITE_TOOLS = {
   write = true,
   edit = true,
   edit_lines = true,
   multiedit = true,
}

-- tool_id -> true when that call is editing a .allium file. Keyed by id so
-- concurrent edits (batch, subagents) don't leak into each other.
local pending_allium = {}

local function is_allium_path(p)
   return type(p) == "string" and p:match "%.allium$" ~= nil
end

-- Wrap each write tool's input slot to flag .allium edits. Returning nothing
-- is a true no-op, so we never alter the call itself. Costs fs_write, which
-- these tools declare, so the plugin must hold it (see plugin.toml).
for name in pairs(WRITE_TOOLS) do
   maki.api.set_slot("tool." .. name .. ".input", function(prev, input, ctx)
      if input and is_allium_path(input.path) and ctx and ctx.tool_id and ctx.tool_id ~= "" then
         pending_allium[ctx.tool_id] = true
      end
      return prev(input, ctx)
   end)
end

maki.api.create_autocmd("ToolDone", {
   callback = function(ev)
      local tool = ev.data and ev.data.tool
      if not tool or not WRITE_TOOLS[tool] then
         return
      end

      -- Only proceed if this specific call edited a .allium file.
      local tool_id = ev.data and ev.data.tool_id
      if not tool_id or not pending_allium[tool_id] then
         return
      end
      pending_allium[tool_id] = nil

      if maki.fn.executable "allium" ~= 1 then
         return
      end

      local session_id = ev.data and ev.data.session_id
      local lines = {}
      local function collect(_, line)
         if line and line ~= "" then
            lines[#lines + 1] = line
         end
      end
      maki.fn.jobstart({ "allium", "check" }, {
         scope = "plugin",
         on_stdout = collect,
         on_stderr = collect,
         on_exit = function(_, code)
            if code ~= 0 and #lines > 0 then
               local report = "[allium check] found issues:\n" .. table.concat(lines, "\n")
               maki.session.notify(report, { session = session_id, wake = false })
            end
         end,
      })
   end,
})
