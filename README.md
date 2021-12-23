# SSL Certification Expire Check Script

fetch SSL Certification Expire Date

# development

## MacOSX: Catalina 10.15.7

## bash: 5.1.12

## GNU date: (GNU coreutils) 9.0

# run

~~~
checker.sh [-f file] [-u url] [-h]
~~~

DATE environment variable specify gnu date command. if you have installed "GNU date" by home brew on your Mac. set "gdate". 

~~~
DATE=gdate checker.sh -u https://example.com
~~~

~~~
DATE=gdate checker.sh -f hosts.txt
~~~

# output
single site, 1st column remain expire days

~~~
DATE=gdate checker.sh -u https://example.com
352,https://example.com, Dec  9 23:59:59 2022 GMT
~~~

multi sites
~~~
DATE=gdate checker.sh -f hosts.txt
071,https://qiita.com/, Mar  3 23:59:59 2022 GMT
000,http://www.yahoo.co.jp, NO SSL
381,https://www.yahoo.co.jp, Jan  8 14:59:00 2023 GMT
000,http://www.google.co.jp, NO SSL
060,https://www.google.co.jp, Feb 21 03:57:45 2022 GMT
000,https://expired.badssl.com,  certificate has expired
000,https://self-signed.badssl.com/,  self signed certificate
000,https://untrusted-root.badssl.com/,  self signed certificate in certificate chain
~~~

sort command friendly
~~~
DATE=gdate ./checker.sh -f hosts.txt|sort
000,http://www.google.co.jp, NO SSL
000,http://www.yahoo.co.jp, NO SSL
000,https://expired.badssl.com,  certificate has expired
000,https://self-signed.badssl.com/,  self signed certificate
000,https://untrusted-root.badssl.com/,  self signed certificate in certificate chain
060,https://www.google.co.jp, Feb 21 03:57:45 2022 GMT
071,https://qiita.com/, Mar  3 23:59:59 2022 GMT
381,https://www.yahoo.co.jp, Jan  8 14:59:00 2023 GMT
~~~

# Limitation

it doesn't support redirection, therefore

~~~
DATE=gdate bash checker.sh -u http://google.com 
000,http://google.com, NO SSL
DATE=gdate bash checker.sh -u https://google.com
060,https://google.com, Feb 21 02:22:32 2022 GMT
~~~