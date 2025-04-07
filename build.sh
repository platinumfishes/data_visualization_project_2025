#!/bin/bash

# Ensure you are in the correct directory
dir1=${PWD}

# Pull latest changes from GitHub (optional, ensure you are up to date)
echo "Pulling latest changes from GitHub..."
git pull

# Start fresh by removing the _site folder
echo "Cleaning up previous _site folder..."
rm -rf _site

# Build the website using Quarto
echo "Building the website with Quarto..."
quarto render

# Clean up .DS_Store files if present
echo "Removing .DS_Store files..."
cd _site; find ./ -name .DS_Store -exec rm {} \; ; cd "$dir1"

# Set correct file and directory permissions for the _site folder
echo "Setting correct permissions for files and directories..."
for i in $(find _site -type f); do chmod 644 $i; done
for i in $(find _site -type d); do chmod 755 $i; done

# GitHub Sync Logic
printf 'Would you like to push to GITHUB? (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    git config http.postBuffer 20242880000  # Increase postBuffer for large files

    # Pull the latest changes from GitHub repo
    echo "Pulling latest changes from GitHub repository..."
    git pull

    # Sync changes to local repo and commit
    read -p 'ENTER COMMIT MESSAGE: ' message
    echo "Commit message: $message" 
    git add ./  # Add all changed files
    git commit -m "$message"  # Commit changes
    git push  # Push to GitHub

else
    echo "Not pushing to GitHub!"
fi

# Push the website to Georgetown Domains
printf 'Would you like to push to GU domains? (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    # Specify the remote path on Georgetown Domains (ensure this path is correct)
    echo "Pushing the website to Georgetown Domains..."

    rsync -alvr --delete _site/* allenwug@allenwu.georgetown.domains:/home/allenwug/public_html/broadband_project/

else
    echo "Not pushing to GU domains!"
fi
