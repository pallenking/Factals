-- Define the path to the Pages file and the output movie file
set pagesFilePath to "/path/to/your/document.pages"
set outputMoviePath to "/path/to/output/movie.mp4"

-- Create a temporary directory to store extracted images
do shell script "mkdir -p /tmp/pages_images"

-- Function to extract images from the Pages file
on extractImagesFromPages(pagesFile)
    do shell script "unzip -o " & quoted form of pagesFile & " -d /tmp/pages_extract"
    do shell script "cp /tmp/pages_extract/Data/Images/*.jpg /tmp/pages_images/"
    do shell script "rm -rf /tmp/pages_extract"
end extractImagesFromPages

-- Function to process git commits and extract images
on processCommits(pagesFile)
    do shell script "git checkout master"
    set commitList to paragraphs of (do shell script "git log --format=%H")
    repeat with commitID in commitList
        do shell script "git checkout " & commitID
        extractImagesFromPages(pagesFile)
    end repeat
    do shell script "git checkout master"
end processCommits

-- Function to create a video from extracted images using FFmpeg
on createVideoFromImages(outputPath)
    do shell script "ffmpeg -framerate 1 -pattern_type glob -i '/tmp/pages_images/*.jpg' -c:v libx264 -r 30 -pix_fmt yuv420p " & quoted form of outputPath
    -- Clean up the temporary directory
    do shell script "rm -rf /tmp/pages_images"
end createVideoFromImages

-- Main script execution
processCommits(pagesFilePath)
createVideoFromImages(outputMoviePath)
