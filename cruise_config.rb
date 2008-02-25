Project.configure do |project|
  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  project.email_notifier.emails = [ 'studiotrak-devel@colortechnology.com' ]
  
  project.rake_task = 'cruise'
end