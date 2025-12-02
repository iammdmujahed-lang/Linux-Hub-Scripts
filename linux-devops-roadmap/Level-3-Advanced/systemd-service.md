# Custom systemd Service

Example unit file: /etc/systemd/system/myapp.service

[Unit]
Description=My App
After=network.target

[Service]
User=devuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/java -jar /opt/myapp/app.jar
Restart=on-failure

[Install]
WantedBy=multi-user.target
