#!/usr/bin/env fish

# Create assets/icons directory if it doesn't exist
mkdir -p assets/icons

# Base URL for dashboard icons
set base_url "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons"

# Extract unique icon names from yml files
set icon_names (grep -h 'icon: di:' config/*.yml | sed 's/.*di://' | sort -u)

# Function to try downloading in different formats
function try_download
    set icon_name $argv[1]
    set formats svg webp png

    for format in $formats
        set url "$base_url/$format/$icon_name.$format"
        set output_file "assets/icons/$icon_name.$format"
        echo "Trying URL: $url"

        # Try to download the file with more options for debugging
        set curl_result (curl -L -w "%{http_code}" -o "$output_file" "$url" 2>/dev/null)

        if test $curl_result -eq 200
            echo "✓ Successfully downloaded $icon_name in $format format"
            return 0
        else
            echo "✗ Failed to download in $format format (HTTP $curl_result)"
            rm -f "$output_file"
        end
    end

    echo "Warning: Could not download $icon_name in any format"
    return 1
end

# Download each icon
echo "Found these icons to download:"
printf "%s\n" $icon_names

for icon in $icon_names
    echo "Processing: $icon"
    try_download $icon
end

echo "Done downloading icons!"
