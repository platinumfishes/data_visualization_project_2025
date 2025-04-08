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

# Function to push to GitHub Pages under /docs
push_to_github_pages() {
    # Ensure we are in the correct directory
    cd _site

    # Create a new branch specifically for GitHub Pages if needed
    echo "Switching to gh-pages branch..."
    git checkout -b gh-pages || git checkout gh-pages

    # Add the _site contents to the /docs directory
    echo "Syncing _site to the /docs directory..."
    cp -r * ../docs/

    # Commit and push to GitHub Pages
    echo "Committing and pushing changes to GitHub Pages..."
    git add .
    git commit -m "Update GitHub Pages site"
    git push origin gh-pages

    # Go back to the main branch
    git checkout main
    cd "$dir1"
}

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

    rsync -alvr --delete _site/* allenwug@allenwu.georgetown.domains:/home/allenwug/public_html/scholarship_project

else
    echo "Not pushing to GU domains!"
fi

# Push the website to GitHub Pages under /docs
printf 'Would you like to push the website to GitHub Pages (under /docs)? (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    push_to_github_pages
else
    echo "Not pushing to GitHub Pages!"
fi
