This html-template contains 3 important files that you should know of:
1 - index.template.html - where you configure your flashvars. this is the place to point to your partners details, and your partner content. 
2 - config.xml - this file is a local configuration file for the ui and functionality of the VDP. normally this config file will be loaded from a vidiun service, this file bypasses the loaded file so you could edit the uiConf easily. If you change this file, make sure that there is a copy of your changes in the bin-debug folder.
3 - config_playlist.xml - this is a configuration of a typical playlist. if you want to test a playlist - copy the content of this text file to the config.xml file, and change the dimanssions of the player in the html-template file.

All templates are configured to "fileSystemMode=false", so you should run these pages through your localhost (or change fileSystemMode value).  
for more uiConf documentation see uiConf.docx in 'docs' folder in the vdp3Lib project 


  
 