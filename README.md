# Vivado-HLS
to access the Vivado GUI using a MAC's built in Screen Sharing application:
- have one terminal open, ssh'd into the EC2 instance
```ssh -i <path to .pem key> ec2-user@<ip address>```


- in another terminal window, run
```ssh -i <path to .pem key> -L 5901:localhost:5901 ec2-user@<ip address>```


