#!/usr/bin/python
# -*- coding: utf8 -*- 

import os

def xcmd(run_message, command, failure_message):
	if run_message is not None:
		print run_message

	print(command)
	exit_status = os.system(command)
	if exit_status:
		print failure_message
		exit(1)
		
def xcopy(run_message, source, dest, failure_message):
	if run_message is not None:
		print run_message
	
	command = "cp -R "+ source +" "+ dest
	print command
	exit_status = os.system(command)
	if exit_status:
		print failure_message
		exit(1)

def xremove(run_message, name, failure_message):
	if os.path.exists(name):
		if run_message is not None:
			print run_message

		exit_status = os.system("rm -R "+name)
		if exit_status:
			print failure_message
			exit(1)


def make_MacOSX(source_name, base_name):
	"""Mac OS X

	As of 0.6.1, it is now easier to create ready-to-distribute stand-alone Love games by following these steps:

	First create a copy of the löve.app
	Right-click (Control+Click if you have one button) to bring up the contextual menu and select "Show Package Contents"
	Navigate to Contents/Resources/. There should be two .icns files in there. Copy your already prepared .love file into Resources.
	Next, you need to edit /Contents/Info.plist. The main reason is that if you don't, your game will conflict with another LÖVE installation present on the user's machine, so that double-clicking any .love might open your game instead. The reasons are that when you launch the game, the Dock icon is still the default löve icon and the title is "love". To change this, all you need is a small amount of computer knowledge and the right tools. A text editor, or the OS X Property List Editor.app which comes with the Developers tools on the install disc. You can use either, but the PLE is easier to understand. The file you need to modify is the Info.plist file located in the Contents folder. Once opened in PLE, you will see a list of "properties". You only need to change a couple: (Make sure to double-click the "Value" column and not the "Key".

	Bundle identifier - Make this something like com.yourcompany.whatever
	Bundle name - Changes the title in the Dock
	Bundle OS Type code
	Bundle creator OS Type code - Make these unique so .love files don't open with your game
	Icon file - Optionally if you wish to make your icon a different file name. You could just replace the icon itself if you wanted to without renaming it though"""
	
	app_name = base_name + '.app'
	
	if os.path.exists(app_name):
		print "Remove app"
		exit_status = os.system("rm -R "+app_name)
		if exit_status:
			print "Problem removing"
			exit(1)
	
	print "Copy app"
	exit_status = os.system("cp -R "+ source_name +" "+app_name)
	if exit_status:
		print "Problem copying"
		exit(1)
		
	# copy Info.plist
	print "copy plist"
	exit_status = os.system("cp -f mac_resources/info.plist "+app_name+"/Contents")
	if exit_status:
		print "Problem copying"
		exit(1)

	# copy PkgInfo
	print "copy PkgInfo"
	exit_status = os.system("cp -f mac_resources/PkgInfo "+app_name+"/Contents")
	if exit_status:
		print "Problem copying"
		exit(1)

	# remove old icons
	print "removing old icons [1]"
	exit_status = os.system("rm "+app_name+"/Contents/Resources/Love.icns")
	if exit_status:
		print "Problem removing"
		exit(1)
	print "removing old icons [2]"
	exit_status = os.system("rm "+app_name+"/Contents/Resources/Lovedocument.icns")
	if exit_status:
		print "Problem removing"
		exit(1)

	# add new icon
	print "copy icon"
	exit_status = os.system("cp mac_resources/RP_Platform.icns "+app_name+"/Contents/Resources")
	if exit_status:
		print "Problem copying"
		exit(1)
	
	# copy love file across
	print "copy love"
	exit_status = os.system("cp Platform.love "+app_name+"/Contents/Resources")
	if exit_status:
		print "Problem copying"
		exit(1)


	# finally pack it for distribution
	#xcmd("Pack distribution", "cd Windows_versions; zip -r "+dest2+".zip "+dest2, "zip failed")
	#xcmd(None, "unzip -l "+dest+".zip", "list failed")
	# hdiutil create ./dist/FileExplorer.dmg -srcfolder ./dist/ -ov
	# -ov Allows the file to be overidden if it is already there, 
	# https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man1/hdiutil.1.html
	# http://munkymorgy.blogspot.co.uk/2009/01/create-dmg-files-from-command-line.html
	#
	dist_name = base_name+"_dist"
	xremove("Removing dist", dist_name, "Failed removing dist")
	# create a dist folder

	xcmd("Creating dist folder", "mkdir "+dist_name, "Failed creating dist Folder")
	xcopy(None, app_name, dist_name, "Failed copy app")
	xcopy(None, "platform_README.txt", dist_name, "Failed copy readme")
	
	# now pack this folder into a dmg folder
	xcmd("Packing distribution", "hdiutil create "+base_name+".dmg -srcfolder "+dist_name+" -ov", "Failed packing dist")
	xremove("Removing dist", dist_name, "Failed removing dist")
	
	print "Finished MacOSX vesion", app_name
	print


def make_love():
	# create new love file
	print "create love"
	exit_status = os.system("cd Platform; zip -r ../Platform.love *")
	if exit_status:
		print "Problem zipping"
		exit(1)

	# zip love
	print "create love"
	exit_status = os.system("zip -d Platform.love media/.DS_Store")
	if exit_status:
		print "Problem removing .DS_Store"
		#exit(1)
	
	print "zip contains"
	exit_status = os.system("unzip -l Platform.love")


def make_Win(source, dest1, dest2):

	dest = dest1+'/'+dest2
	exe_name = dest+"/platform.exe"
	
	if os.path.exists(exe_name):
		print "Removing exe"
		exit_status = os.system("rm -R "+exe_name)
		if exit_status:
			print "Problem removing"
			exit(1)

	# copy the exe and add the love file onto the exe
	print "copy love.exe and add love to exe"
	command = "cat Platform.love "+source+"/love.exe > "+exe_name
	print(command)
	exit_status = os.system(command)
	if exit_status:
		print "Problem copy exe"
		exit(1)
		
	# copy the exe
	#xcopy("Copy Executable", source, dest, "Problem copying executable")
	
	# copy the libraries
	xcopy("Copy Libraries", source+"/DevIL.dll", dest, "Problem copying DevIL")
	xcopy(None, source+"/OpenAL32.dll", dest, "Problem copying OpenAL32")
	xcopy(None, source+"/SDL.dll", dest, "Problem copying SDL")

	# copy the readme
	xcopy("Copy readme", "platform_README.txt", dest, "Problem copying readme")
	
	# finally zip it for distribution
	xcmd("Pack distribution", "cd Windows_versions; zip -r "+dest2+".zip "+dest2, "zip failed")
	xcmd(None, "unzip -l "+dest+".zip", "list failed")
	
	print "Finished Windows version", dest

def main():
	make_love()
	make_MacOSX("love.app", "platform_intel_mac")
	make_MacOSX("PowerPC_version/love.app", "PowerPC_version/platform_ppc_mac")
	make_Win("love-0.8.0-win-x86", "Windows_versions", "platform_x86_win")
	make_Win("love-0.8.0-win-x64", "Windows_versions", "platform_x64_win")

main()

