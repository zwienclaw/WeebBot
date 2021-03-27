# WeebBot
Web scraper to update user on new manga/anime updates.

Leverages Twilio messaging api to send text updates. You will need to setup an account or follow instructions in script file to use Send-MailMessage instead.

Send-MailMessage will look very similar except you will need to find the SMTP server and Support connection strings for your services.

Uses manganelo.com for manga scrapping.

Excel spreadsheet contains Name and chapter column. This will need to be manually updated to send updates for new manga or leverage twilio api to set up a bot to automate.
