var fs = require('fs');
var execSync = require('child_process').execSync;
var videoExt = [ ".mp4", ".mov", ".m4v", ".mpg", ".MP4", ".MOV", ".M4V", ".MPG" ];
/* ffmpeg -i $1 -ss 00:00:01.000 -vframes 1 $1.png */
var genVidThumbCmd = "ffmpeg";
var removeCmd = "rm ";
var genVidOptions = " -ss 00:00:01.000 -vframes 1 ";
var thumbdir = ".thumbnails";
var rootVideoDir;
var bThumbs = false;
var bMonitor = false;
var bVideoCompress = false;



function processVideoFile(directory, filename)
{
	var newname;
	
	if (is_video(filename))
	{
		/* Found at least one video file in this directory, so I need to 
		   create a .thumbnails directory
		   
		   then generate the thumbnail is it doesn't exist
		   
		*/
		
		if (!fs.existsSync(directory + "/" + thumbdir))
		{
			/* How do I check for error?? */
			console.log("Creating " + directory + "/" + thumbdir);
			try {
				fs.mkdirSync(directory + "/" + thumbdir);
			}
			catch(e) {
				console.log("File " + directory + "/" + thumbdir + "   Error: " + e);
			}
		}	
		
		/* Check for spaces and parens in the filename
			- I hate spaces in a filename
			- if you find a file with spaces in the name, replace the spaces with dashes
			- turns out that I also hate parens ( or ) so just remove those
			- use RegExp,  the [ ] act as an or so if it finds any of the characters inside the brackets, it is a match
		*/
		if ( filename.search(/[ \(\)]/g) > -1) 
		{
			var newname = filename.replace(/ /g,"-").replace(/[\(\)]/g,"");
			console.log("Found spaces in filename, I hate that, renaming file to: " + newname);
			fs.renameSync(directory + "/" + filename,directory + "/" + newname);
			filename = newname;
		}
		
		if (!fs.existsSync(directory + "/" + thumbdir + "/" + filename + ".png"))
		{
			/* Gen thumbnail */
			console.log("Generating Thumbnail for video: " + directory + "/" + filename);
			var cmd = genVidThumbCmd + " -i " + directory + "/" + filename + genVidOptions + directory + "/" + thumbdir + "/" + filename + ".png";
			console.log("  command: " + cmd);
			stdout = execSync(cmd,{encoding: 'ascii'});
			console.log(stdout);
		}
		else
		{
			console.log("Thumbnail " + directory + "/" + thumbdir + "/" + filename + ".png already exists");
		}
		
		if (bVideoCompress)
		{
			/* need to figure out the year, based on directory name and date of file */
			
			/* need to figure out the filename, based on the directory name */
			if (!fs.existsSync(vid_compress_directory + "/" + yeardir + "/" + filename + ".mp4"))
			{
				/* Generate compressed video clip */
				console.log("Generating compressed video clip for source video: " + directory + "/" + filename);
				
				/* call FFMPEG to generate video */
				
				/* create entry in index file */
				
				/* process video for facial recognition */

			}
		
		}
		
		
	}
}

function deleteVideoFile(directory, filename)
{
	if (is_video(filename))
	{
		/* A video file was deleted, so remove the thumbnail */	
		if (fs.existsSync(directory + "/" + thumbdir))
		{
			if (fs.existsSync(directory + "/" + thumbdir + "/" + filename + ".png"))
			{
				/* delete thumbnail */
				console.log("Deleting Thumbnail for video: " + directory + "/" + filename);
				var cmd = removeCmd + directory + "/" + thumbdir + "/" + filename + ".png";
				console.log("  command: " + cmd);
				stdout = execSync(cmd,{encoding: 'ascii'});
				console.log(stdout);
			}
			else
			{
				console.log(directory + "/" + filename + " deleted, but " + directory + "/" + thumbdir + "/" + filename + ".png does not exist");
			}
		}
		else
		{
			console.log(directory + "/" + filename + " deleted, but " + directory + "/" + thumbdir + " does not exist");
		}
	}
}


function traverseDir(directory, processFile)
{
	/* Get a list of file in the directory, generate thumbnails for all video files,
	   recursively call this function for each Directory 
	   
	   Use the Synchronous version of the filesystem APIs.  The async versions make this too 
	   complicated.   
	   
	*/
	var filelist = fs.readdirSync(directory);
	
	if (filelist != undefined)
	{
		var i;
		var stdout;
		
		for (i = 0; i < filelist.length; i++)
		{
			/* skip any "hidden" files or directories */
			if (filelist[i].charAt[0] != ".")
			{
				console.log(directory + "/" + filelist[i]);
				try 
				{
					var stat = fs.statSync(directory + "/" + filelist[i]);
					if (stat.isFile())
					{
						processFile(directory, filelist[i]);
					}
					else if (stat.isDirectory())
					{
						console.log("Going into directory: " + filelist[i]);
						traverseDir(directory + "/" + filelist[i],processFile);
					}
				}
				catch(e)
				{
					console.log("File: " + filelist[i] + "   Error: " + e);
				}
			}
		}
	}
}

function watchdir(rootdir, processFile, deleteFile)
{
	console.log("Watching Directory Tree with root " + rootdir + " for video files");
	fs.watch(rootdir,{ persistent: true, recursive: true }, function (event, path) {
	  console.log('event is: ' + event);
	  if (path) {
		console.log('filename provided: ' + path);
		
		/* if filename provided, then take action on file */
		switch (event)
		{
			case "change":
			case "rename":
				/* The rename or change event will fire for the creation of a new file or the delete of an 
				   existing file 
				   
				   Multiple events will be received for the creation of one file, and will be processed, but 
				   if the thumbnail will not be created if it already exists...
				*/
				if (fs.existsSync(rootdir + "/" + path))
				{
					var stat = fs.statSync(rootdir + "/" + path);
					if (stat.isFile())
					{   
						/* separate directory and filename */
						var directory = rootdir;
						var filename = path;
						var slash = path.lastIndexOf("/");
						if (slash != -1)
						{
							filename = path.slice(slash+1,path.length);
							directory += "/" + path.slice(0,slash);
						}
						console.log("ProcessFile: " + directory + "/" + filename);
						processFile(directory, filename);
					}
				}
				else
				{
					/* file does not exist, must have been deleted */
					
						/* separate directory and filename */
						var directory = rootdir;
						var filename = path;
						var slash = path.lastIndexOf("/");
						if (slash != -1)
						{
							filename = path.slice(slash+1,path.length);
							directory += "/" + path.slice(0,slash);
						}
						console.log("DeleteFile: " + directory + "/" + filename);
						deleteFile(directory, filename);
				}
			break;
						
			default:
				console.log("Unknown event: " + event + " on file " + path);
			break;
		}
	  } else {
		console.log('filename not provided');
	  }
	});
}


function is_video(filename)
{
	/* console.log("is_video: " + filename); */
	for (var i = 0; i < videoExt.length; i++)
	{
		/*
		console.log("is_video: " + videoExt[i]);
		console.log("is_video: " + filename.search(videoExt[i]));
		*/
		/* only match if the one of the video extensions is at the end of the filename */
		if ( (filename.length - filename.search(videoExt[i])) == videoExt[i].length)
		{
			return true;
		}
	}
	return false;
}
		
		
if (process.argv[2])
{
	rootVideoDir = process.argv[2];
	
	/* First traverse the entire directory structure, and generate any missing thumbnails for all video files, 
	*/
	traverseDir(rootVideoDir, processVideoFile);

	/* Now setup a filesystem watch on the entire directory tree and whenever a video file is added generate the thumbnail,
	   and delete the thumbnail when a video is removed.
	*/
	watchdir(rootVideoDir, processVideoFile, deleteVideoFile);
	
}
else
{
	console.log("Usage: node genthumbs-recursive <root directory>");
}
