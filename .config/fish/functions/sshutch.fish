function sshutch
    while true
        # Prompt the user to pick a machine

        set availableMachines 01 02 03 04 05 06 07 08 09 10 11 12
        set userInput (gum input --placeholder "Which Lab Machine? (01-12) (q or quit to cancel)")

        # set availableMachines 01 02 03 04 05 06 07 08 09 10 11 12
        # set userInput (gum choose $availableMachines)

        # Check if the user input is a valid machine
        if test (echo "$availableMachines" | grep $userInput)
            gum style --foreground 212 "Connecting to hutch-$userInput..."
            #echo "cd /research/hutchinson/workspace/newmanp/" | ssh -t cf408-hut-$userInput
            ssh cf408-hut-$userInput
	    return
        end

        # End the loop if the user enters q or quit
        if test (echo "q quit" | grep $userInput)
            return
        end
    end
end
