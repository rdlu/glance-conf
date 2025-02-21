#!/usr/bin/env fish

# Function to find the actual format of a downloaded icon
function get_icon_format
    set icon_name $argv[1]
    set formats svg webp png

    for format in $formats
        if test -f "assets/icons/$icon_name.$format"
            echo $format
            return 0
        end
    end
    return 1
end

# Process each yml file in the config directory
for yml_file in config/*.yml
    echo "Processing file: $yml_file"

    # Create a temporary file
    set temp_file (mktemp)

    # Process the file line by line
    while read -l line
        # Check if the line contains a di: icon
        if string match -q "*icon: di:*" -- "$line"
            # Extract the icon name
            set icon_name (string replace -r ".*icon: di:" "" -- "$line")

            # Find the format that was downloaded
            set format (get_icon_format $icon_name)

            if test $status -eq 0
                # Replace the di: reference with the local path
                set new_line (string replace -r "icon: di:.*" "icon: /assets/icons/$icon_name.$format" -- "$line")
                echo $new_line >>$temp_file
            else
                # If no local icon found, keep the original line
                echo $line >>$temp_file
            end
        else
            # Keep lines without di: icons unchanged
            echo $line >>$temp_file
        end
    end <$yml_file

    # Replace the original file with the modified content
    mv $temp_file $yml_file
end

echo "Done updating icon paths in yml files!"
