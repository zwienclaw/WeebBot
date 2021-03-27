# WeebBot
Web scraper to update user on new manga/anime updates.

Leverages Twilio messaging api to send text updates. You will need to setup an account or follow instructions in script file to use Send-MailMessage instead.
Can also be updated to leverage a bot that can wait for a response before updating the CSV document.

Send-MailMessage will look very similar except you will need to find the SMTP server and Support connection strings for your services.

Uses manganelo.com for manga scrapping.

Excel spreadsheet contains Name and chapter column. This will need to be manually updated to send updates for new manga or leverage twilio api to set up a bot to automate.
Leaving some recommendations of manga I follow for anyone. Update the CSV to accomodate your manga followings or update the chapter column to current chapter you're on or just set it to 0 to get any future updates and to be recorded in the CSV.
