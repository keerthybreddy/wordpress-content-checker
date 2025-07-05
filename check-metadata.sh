# print statement to indicate beginning of template validation
echo "Running template validation..."

# declares a variable named report and assigns it the string value of the report file name
report="validation-report.md"

# adding a title + formatting to the validation report
echo "Template Validation Report" > "$report"
echo "" >> "$report"

# declares a variable named failures to track the number of times (if any) the Wordpress posts don't match the template
failures=0

# Once fetch-posts.js uploads HTML files of the most recent Wordpress posts to the content folder, each file will be iterated through to validate against the template
for file in content/*.html; do
  
    # prints the current file being validated
    echo "Checking $file"

    # for each file being validated, a variable called missing appends missing or invalid metadata to a string
    missing=""
  
    # checks if the <title> tag exists in the current HTML file
    if grep -q "<title>" "$file"; then
    
        # uses Perl-compatible Regex to store the text between the title tags in a variable called title_content
        title_content=$(grep -oP '(?<=<title>).*?(?=</title>)' "$file" | xargs)

        # checks whether the string in title_content is equal to "Untitled" or an empty string, then append "invalid-title" to the missing string to record it
        if [ -z "$title_content" ] || [ "$title_content" = "Untitled" ]; then
            missing="$missing invalid-title"
        fi

    # if the <title> tag doesn't exist at all, append "missing-title" to the missing string variable
    else
        missing="$missing missing-title"
    fi

    # checks if the post has a meta tag for the post description 
    if grep -q '<meta name="description"' "$file"; then

        # uses Regex to store the value in the content of the meta tag for the description in a variable called description
        description=$(grep -oP 'meta name="description" content="\K[^"]*' "$file" | xargs)
        
        # checks whether the content of the description variable is an empty string or has placeholder text and if so, appends "empty-description" to the missing string variable
        if [ -z "$description" ] || [ "$description" = "No description available" ]; then
            missing="$missing invalid-title"
        fi
    else

        # if the description meta tag dosen't exist at all, appends "missing-description" to the missing string variable
        missing="$missing missing-description"
    fi

    # checks if the post has a meta tag for an image
    if grep -q 'meta property="og:image"' "$file"; then

        # uses Regex to store the value in the content of the meta tag for the image in a variable called image
        image=$(grep -oP 'meta property="og:image" content="\K[^"]*' "$file" | xargs)
        
        # checks whether the content of the image variable is an empty string and if so, appends empty-og:image in the missing string variable
        [ -z "$image" ] && missing="$missing empty-og:image"
    else

        # if the image meta tag dosen't exist at all, appends missing-og:image to the missing string variable
        missing="$missing missing-og:image"
    fi

    # Check all <img> tags for valid alt values
    if grep -q '<img' "$file"; then
        
        # Use regex to extract all <img> tags from the file and append them to a variable called img_tags
        img_tags=$(grep -oP '<img[^>]*>' "$file")

        # loops through each line in the img_tags variable 
        while IFS= read -r img; do

            # Check if alt attribute exists and is non-empty for every <img> tag and if so appends invalid-alt to the missing string variable
            if ! echo "$img" | grep -q 'alt="[^\"]\+"' ; then
                missing="$missing invalid-alt"
                break
            fi
        done <<< "$img_tags"
        else

            # If there are no images in the post at all, append missing-image to the missing string variable
            missing="$missing missing-image"
        fi

    # if the missing string is not empty, this indicates that the file format does not satisfy the template
    if [ -n "$missing" ]; then
        
        # print the missing string to show failures
        echo "$file failed: $missing"
        echo "**$file** failed: \`$missing\`" >> "$report"
        
        # set the failures variable equal to 1
        failures=1
    else
        
        # if the missing string is empty, this indicates that the file format of the current file does satisfy the template
        echo "$file passes all checks"
        echo "**$file** passed" >> "$report"
    fi

    echo "" >> "$report"
done

# if the failures variable is not equal to 0, this indicates that at least one of the files within the content folder have failed
    if [ $failures -ne 0 ]; then
        echo "Some files failed validation. See validation-report.md for details."
        exit 1
    else
        echo "All files passed validation."
    fi