---
title: nycki's simple cookbook for Linux, [v0.10.2](https://github.com/nycki93/cookbook)
...

## introduction

### why a cookbook? 

there's an old [joke](https://reddit.com/r/geek/comments/4zl3e1/happy_birthday_linux_heres_your_cake) that using Linux is like ordering a cake and receiving a bunch of flour, sugar, butter, and eggs. many self-hosting tutorials read like the back of a box of cake mix, which is great if you want a cake fast, but unsatisfying if you want to learn about cake making. my goal is for this guide to teach you enough to improvise, to make substitutions.

### why all the lowercase?

a few people have asked me this. honestly I have some [influences](https://seximal.net) but the main reason is that it reminds me of writing code. in code, uppercase letters are almost always reserved for names. I did my best to capitalize all names in this document the way their owners capitalize them, so the web protocol is HTTP, but the comic strip is xkcd.

### who is your audience?

this guide is for you if:

- you're me, and you forgot how you did this last time.
- you want to share pictures and videos and don't want to use a commercial file host.
- you want to run a communal server, like [tilde.club](https://tilde.club).
- you're just curious about Linux and servers!

sound good? then let's get cooking.

## materials

I'll be using a [Raspberry Pi 4b] and installing [Raspberry Pi OS] Lite (64-bit). it's also known as Raspbian, since it's based on [Debian] Linux. any Debian-like OS will work for this tutorial. if the Raspberry Pi isn't available where and when you are, some good alternatives are the [Renegade] or the [ROCK64]. If Raspbian doesn't run on your device, try [armbian].

you'll also need a MicroSD card, a hard drive, and a second hard drive for backup. I recommend a 64GB MicroSD card and two 2TB hard drives. the Pi can power one hard drive via USB, but if you want to plug both in at once you'll need a powered hard drive enclosure or a powered USB hub.

you can also adapt these directions to existing hardware you may already own, like an old laptop or desktop pc. you can also rent a virtual machine from a remote datacenter! the cheapest virtual machine on [DigitalOcean] right now (as of 2023 July) costs 6 USD per month, and comes with 25GB of storage. renting a machine in a datacenter means you get the perks of high-speed internet all day and night, which is great if you are running a game server and need a fast connection. however, you'll pay 10 USD per month for each 100GB of additional storage, so it's not great if you want to host a huge media archive.

<!-- todo: what about S3-compatible storage? -->

[Raspberry Pi 4b]: https://www.raspberrypi.com
[Raspberry Pi OS]: https://www.raspberrypi.com/software
[Debian]: https://www.debian.org/doc
[Renegade]: https://libre.computer/products/roc-rk3328-cc
[ROCK64]: https://www.pine64.org/devices/single-board-computers/rock64
[armbian]: https://www.armbian.com
[DigitalOcean]: https://www.digitalocean.com

## usernames and passwords

at some point you'll probably want to make your server available on the internet. there are bots out there that do nothing but guess random usernames and passwords all day, and they *will* find you, so you need to be prepared.

for your username, pick something short and catchy. in my experience, a typical linux username is from 3 to 8 characters long. if you have a short name like 'alice' or 'bob' you can use that. if you have a nickname online like 'azure' or 'luna' then that works too. if you have a middle name, you can use your initials, like 'jfk'. your username should be all lowercase.

for your password, the most important factor is length. maybe you've been told that you need to add weird symbols and stuff in it, but that rule is for more limited systems. it's the 64-bit era, baby! the only thing that matters is how much entropy your password has. **entropy** is basically a measure of how unlikely something is to happen by accident. like if I flip ten coins and you flip ten coins and we get the same sequence, the odds of that happening are 1 in 2^10, so we say that that particular sequence of flips has 10 'bits' of entropy. it's recommended that your password have about 60 to 80 bits of entropy. yikes, that's a lot of coin flips to memorize!

luckily there's a better way. using a tool like [xkpasswd](https://xkpasswd.net/s/) or [diceware](https://theworld.com/~reinhold/diceware.html), you can convert randomness into words. using the diceware list, you can roll 25 six-sided dice to get a random 25-digit sequence, and then convert each 5 digits into a word, to get a 5-word phrase. the odds of two people getting the same 5-word phrase are 1 in 6^25, which is approximately equal to 2^64, so this password has 64 bits of entropy. that's enough to make most hackers give up and move onto an easier target. go generate a password now, and save it somewhere safe, like a password manager program, or a piece of paper tucked inside a book. don't be afraid to write things down; sometimes paper is safer.

## operating system

time to download and install your operating system. there are lots of guides on how to install Linux already, [here's](https://www.raspberrypi.com/documentation/computers/getting-started.html) one for Raspbian. I'll be using Raspberry Pi OS Lite (64-Bit), with the default settings. with these settings, there is no remote login available; you will need to plug a keyboard and monitor directly into the pi. on the first boot, you'll be prompted to enter the username and password for the initial user. after that, you'll be given a login prompt. log in with the username and password you just set. some operating systems display nothing at a password prompt, not even stars. once you log in, you'll see some system information, and then a prompt that looks like this:

```
user@raspberrypi:~ $
```

this is a **CLI**, a command line interface. from left to right, this contains

- your name.
- the machine's name.
- your current directory. `~` means "home", and is short for `/home/user`.
- a command prompt. this will be `$` if you are in user mode, or `#` if you are in admin mode.

if you've ever used a bot in a chatroom, you already know how to use a command line interface! it's a system where you type an instruction, and the computer answers you. here are some examples of commands you can type:

- `whoami`: ask the computer what your name is.
- `hostname`: ask the computer what *its* name is.
- `pwd`: ask the computer where you are.
- `ls`: look at the files in your current location.
- `cd <somewhere>`: go somewhere else.
- `echo <something>`: ask the computer to repeat something back to you.
- `nano <filename>`: edit a text file.
- `cat <filename>`: print a text file to the screen.

if this is your first time using a command line interface, try some of these commands now. use `nano myfile.txt` to open a text file, write some text to it, then save with ctrl-o, and exit with ctrl-x. use `ls` to look at that file, then use `cat myfile.txt` to have the computer read it back to you. pat yourself on the back, you're learning so much!

soon we'll unplug the keyboard and monitor from this computer, making it a 'headless' server. before we can do that we need to run a few commands as administrator, or 'root'. we'll do this with a very powerful command called `sudo`. sudo stands for 'super user do', and it means 'do the next thing as an administrator'. you can use `sudo <command>` for a single command, or enter interactive mode with `sudo -i`. in interactive mode, *all* your commands will be admin commands, until you say `exit`.

:warning: **there is no undo button! if you say something with sudo, make sure you mean it!**

throughout this guide, I'll be using `$` at the start of a command if you run it as a normal user, or `#` if you run it as admin. either way, you don't actually type this symbol yourself, it should already appear on your command line.

we'll need to do these things before we can go headless:

- change `sudo` to require a password
- change the hostname from the default
- connect to a network
- enable remote login
- install operating system updates
- reboot

first we'll change the sudo rules for our account. there should be a config file at `/etc/sudoers.d/010_pi-nopasswd`. we'll use the special `visudo` command to edit it, which should launch `nano` like before, but with special safety guards to catch us if we lock ourselves out of administrator mode.
```
$ sudo visudo /etc/sudoers.d/010_pi-nopasswd
```
you should see a single line, like
```
user ALL=(ALL) NOPASSWD: ALL
```
remove the `NOPASSWD:` instruction, so this file reads
```
user ALL=(ALL) ALL
```
save and quit. from now on, if you haven't used `sudo` in a few minutes, the system will ask for your password. this way if you accidentally leave yourself logged in, and someone else takes over your session, they won't automatically get sudo access.

we can do the next few steps with the `raspi-config` tool.
```
$ sudo raspi-config
```
the hostname is under System Options -> Hostname. I set mine to 'teapot'.

if your machine is plugged directly into your home router with a patch cable, you already have network access, otherwise set up wireless with System Options -> Wireless LAN.

to enable remote login, go to Interface Options -> SSH.

select 'Finish'. you'll be prompted to reboot, but don't yet, we'll reboot later after installing some updates. in Debian Linux, we update packages using a tool called `apt`. `apt update` checks for updated packages, and `apt upgrade` installs them. run both these commands now, using the interactive version of `sudo`.
```
$ sudo -i
# apt update
# apt upgrade
```

finally, if you're on a Raspberry Pi, then `avahi-daemon` is installed automatically. if not, you may need to install it yourself. this program broadcasts your hostname to the network, so you can log in remotely without configuring your router.

```
# apt install avahi-daemon
```

now go ahead and reboot, to make sure your new hostname is in use.

```
# reboot
```

after a minute, you should now be able to log in remotely from another computer, using

```
$ ssh user@teapot
```
if this works, congrats! you can now unplug the keyboard and monitor. you've created a headless server.

## format storage

the Raspberry Pi uses a MicroSD card as the operating system disk. it's convenient; if the OS breaks you can just pull its brain out, factory reset it, and pop it back in. however, I don't want to store all my user data on that brain card. I think it's better if you have a secondary disk that contains *only* the stuff you create yourself. that way if something goes wrong and you have to reset the brain card, you don't lose any of your personal data.

there are different formats for a data disk. the format determines exactly where the data and metadata will appear in each 'chunk' of the disk. Windows typically uses [NTFS](https://en.wikipedia.org/wiki/NTFS), which supports metadata for ownership and last modified time, but not for fine-grained access like whether a file is shared with guests. Linux uses a format that does allow this fine-grained access, called [ext4](https://en.wikipedia.org/wiki/Ext4), so that's what we need to format the data disk as.

first we need to identify the disk's device file. in Linux, everything you can read or write to is treated as a file, including a USB device like an external disk. note that this device file is *not* the same as a filesystem mount. we'll cover mounting later.

with the data disk unplugged, run the command `df`. plug the disk in, and run `df` again. compare its output to the previous run. there should be exactly one new entry, and it should look like `/dev/sda` or `/dev/sda2`. if you're not sure which disk it is, don't risk it, ask a friend for help.

<!-- todo: where can you find a friend to ask? -->

:warning: **warning! this will erase everything on the disk!**

format the disk, and label it. this will make it easier to mount later.
```
# mkfs.ext4 /dev/sda
# e2label /dev/sda teapot-data
```

## mount storage

Linux doesn't use drive letters like Windows does. instead, every disk's filesystem lives at some **path**. the main, or 'root' path is `/`, a single slash. the root path belongs to the operating system disk, in this case the MicroSD card. we'll create a new sub-path at `/data` for our data disk.

```
# mkdir /data
```

when the system boots up, it looks in the config file `/etc/fstab` to find out where we want other filesystems to be loaded. since we gave our disk a label earlier, we can mount it using that label. open the file with `nano`, and add this line to the end of it:

```
LABEL=teapot-data /data ext4 nofail,x-systemd.device-timeout=5s,x-systemd.automount 0 0
```

there's a lot going on here. you can [read more](https://www.freedesktop.org/software/systemd/man/systemd.mount.html#fstab) about how fstab and systemd work, but basically what we're saying is

- find the disk labeled 'teapot-data' and mount it at `/data`, as an ext4 filesystem.
- nofail: if the disk is missing at boot time, skip it and finish booting anyway.
- x-systemd.device-timeout=5s: wait 5 seconds before giving up.
- x-systemd.automount: if someone tries to access the disk and it's not mounted, try mounting it again.

we're using a delayed mounting process here because we want to make sure our server still comes online, even if the disk fails to load. if the server crashes on boot, we'll have to go plug the monitor and keyboard back in to fix it. with nofail, we have a chance to fix it remotely.

save and exit the file if you haven't already, and then check it:

```
# mount --all --fake --verbose
```

- --all: apply all the rules from `/etc/fstab`.
- --fake: don't *actually* apply the rules, just check that they're written correctly.
- --verbose: give detailed feedback. Linux programs typically say nothing unless there is an error.

if all your mounts pass inspection, now is a good time to reboot the machine.

```
# reboot
```

## backups

I'll write a longer section about backups later. basically: every month or so, plug in the second disk, and copy everything from the first disk to the second one. it's a quick and dirty solution and it's better than having no backups at all. the command you want is

```
rsync -axHAWXS --numeric-ids --info=progress2 <source> <destination>
```

explanation [here](https://superuser.com/a/1185401).

## website

we're getting into the fun stuff now. one of the coolest things you can do with your Linux server is host a website. a little chunk of the world wide web that belongs just to you. all you need to be a website is to have a program running and ready to answer [HTTP](https://en.wikipedia.org/wiki/HTTP) requests with [HTML](https://en.wikipedia.org/wiki/HTML) text. HTTP is the HyperText Transfer Protocol, and 'HyperText' is just a fancy word for 'text with [hyperlinks](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a) in it'.

put briefly: the internet is made of programs that exchange text files with each other!

we could write a web server from scratch, but to get started we'll use [Apache](https://httpd.apache.org), a free, open-source, and well-established web server. [nginx](https://nginx.org) has a free version too, but Apache is good enough for our purposes.

```
# apt install apache2
```

it should start itself automatically. go ahead and check <http://teapot.local>, and you should see the test page! now we'll write our own page hosted on the data disk. we'll make a folder for it called `/data/teapot.local` and a subfolder of that called `site`.

```
# mkdir /data/teapot.local
# mkdir /data/teapot.local/site
```

when making multiple levels of new directories like this, you can use this shortcut to create the whole chain in one go:

```
# mkdir -p /data/teapot.local/site
```

we're about to do a bunch of typing to set up a basic site definition. you can copy and paste this if you want, but I recommend typing it by hand. it'll train your brain to recognize pieces of the code. remember, use `nano` to create or edit text files.

contents of `/data/teapot.local/site.conf`:

```
<VirtualHost *:80>

ServerName teapot.local
DocumentRoot /data/teapot.local/site

<Directory />
  Require all granted
</Directory>

</VirtualHost>
```

this is just about the simplest possible website definition. we're saying "hi, I am a web server listening to port 80, serving pages for the website 'teapot.local'." a **port** is like a post office box for a computer. it allows you to address a specific program inside the machine. port 80 is an old and well-known port which is used for most HTTP traffic.

next we define the DocumentRoot to be `/data/teapot.local/site`, instead of Apache's default of `/var/www/html`. we also tell Apache that it's allowed to share these files. by default, if no filename is specified, Apache will look for one called `index.html`, so we'll write that too.

contents of `/data/teapot.local/site/index.html`:

```
<!DOCTYPE html>
<html lang="en">
<meta charset="utf-8">
<title>my website!</title>
<h1>my website!</h1>
lorem ipsum dolor sit amet
```

HTML is what your web browser sees. in fact, if you're on a desktop browser, you can press ctrl-u right now to see the HTML text behind *this page!* what I've written for this example is the bare minimum to follow the modern html5 standard.

- originally the `<!DOCTYPE>` tag was used to announce what version of html you were using, but these days we don't really care. we just assume everyone's using 'normal' html.
- the `<html>` tag is traditional, but in html5 it's actually [optional](https://html.spec.whatwg.org/multipage/semantics.html#the-html-element), as is the closing `</html>` tag. we include the opening tag here so we can specify `lang="en"`, which tells the browser that our website is written in English. if you are not writing in English, substitute the appropriate [language code](https://www.w3schools.com/tags/ref_language_codes.asp).
- use a `<meta>` tag to let the browser know we're using utf-8. once upon a time there were different text encodings for every language. it's really a [miracle](https://www.youtube.com/watch?v=MijmeoH9LT4) that utf-8 exists. this encoding was written by the geniuses at [Unicode](https://home.unicode.org). it works great for English, and pretty well for *every other text in every known language.* if this emoji works (⚠️) and isn't displayed like aE` or something, then you can thank utf-8.
- a title! the `<title>` tag is required in html5. this is the text that appears in your browser tab.
- a heading! this is usually the same as the title, but it's optional. `<h1>` is used for the main heading, `<h2>` for a sub-heading, all the way down to `<h6>`.
- finally, I put some [generic text](https://www.lipsum.com) here with no tags at all, just to pad out the page a little.

once you've written both of those files, we can tell Apache our site is ready. by the way, when typing these long paths, try pressing 'tab' once or twice, sometimes your shell will auto-complete words. neat!

```
# ln -s /data/teapot.local/site.conf /etc/apache2/sites-available/teapot.local.conf
# a2ensite teapot.local
# a2dissite 000-default
# systemctl reload apache2
```

now go back to <http://teapot.local> and hit refresh, and you should see your new website! at this point you can go explore the world of HTML. the nice folks at [Neocities](https://neocities.org/tutorials) are helping to keep this art alive, go check them out! and remember, you can press ctrl-u to view the HTML for any page you're on.

*p.s. up until this point I've been writing with pure HTML myself, but as this page is getting rather long, I'm actually switching to a helper tool called [pandoc](https://pandoc.org/). I may cover this tool in a later tutorial.*

## networking

at this point, your server is available only on your **LAN**, your local area network. this network is managed by your **router**, which is a small computer plugged into your home's internet cable. this cable goes to an internet service provider, or **ISP**, and they take the traffic from your network and connect it to other networks around the world. by default, your router will protect your computers from unwanted traffic. people from around the world can't log into your server, and they also can't see your website. if you want to change that, you'll need to change settings on the router.

:warning: **don't modify a home network without consent!** 

if you do this wrong it puts *everyone* on the network at risk, so make sure everyone in your house knows what you're doing. if *anyone* isn't comfortable, then do not open up your home network! you have lots of other options:

- host your website with a free host like [Neocities](https://neocities.org/) or [GitHub Pages](https://pages.github.com/).
- have a friend host instead and share the server with them.
- rent a virtual server from a service like [DigitalOcean](https://www.digitalocean.com/) or [Amazon Web Services (AWS)](https://aws.amazon.com/).

if you're sure you want to open up your home network, read on...

### firewall

if you do everything right, the only server that will be available to the outside world is our little teapot, and only people with an account will be able to get in.

:warning: **you _did_ pick a long, random passphrase, right? if not, go back and do that _now_.**

however, for a little extra safety, we'll use `ufw` to limit what kind of messages teapot will answer. ufw stands for 'Ubuntu firewall' but it works on other systems besides Ubuntu now, so sometimes it's called 'uncomplicated firewall' instead.

:bulb: I got this information almost verbatim from the [Raspberry Pi Foundation](https://www.raspberrypi.com/documentation/computers/configuration.html), seriously they're awesome people.

install `ufw`. unlike other system services, this doesn't start automatically, since you can lock yourself out with it. that's why it's important we configure it *before* changing settings on the router.

```
# apt install ufw
```

we'll also need to know the router's local address. we can find this with the `ip` function.

```
$ ip route
```

the first line of the output should look like this:

```
default via 192.168.20.1 dev eth0
```

if you're using a wireless connection, you'll see wlan0 instead of eth0. underneath the first line, you should see a similar number, but with /24 at the end, like

```
192.168.20.0/24 dev eth0
```

this defines the local **subnet**, the list of IPs that count as part of your local area network. the /24 means that the first 24 bits are fixed. there are 8 bits in a byte, so 24 bits is 3 bytes, meaning that this subnet includes all addresses of the form 192.168.20.x.

to avoid locking ourself out, we'll allow anything from the local area network to connect:

```
# ufw allow from 192.168.20.0/24
```

substitute your own subnet as appropriate. we'll also allow http and https traffic through. ufw has built-in rules that say how to handle this traffic, and it will open the right ports for you.

```
# ufw allow http
# ufw allow https
```

if you want to log in remotely, enable ssh as well:

```
# ufw allow ssh
```

you can check the list of rules with `ufw show added`. if all looks good, turn it on:

```
# ufw enable
```

with any luck, you won't get kicked off your ssh connection, which means the firewall is allowing you through. ufw should now be blocking traffic on all other ports, which will dramatically cut down on the surface area for an attack.

### private key auth

chances are, even if you want to allow outside ssh connections, you don't really need to be able to log in from *anywhere*. most likely you'll only be logging in from one or two machines, like a laptop or your phone. we can configure our server to only allow authenticated devices to connect. 

there's a lot of really advanced math behind private keys, math called **cryptography**, but the important part for our purposes is that each key has a public and a private part. the **public key** can be used to *encrypt* files, "locking" them, but only the **private key** can *decrypt*, or "unlock" them. we'll use this to prove that a device is authorized, by sending a locked message that only it can unlock.

on your laptop or other client device, generate an ssh key. if you're on Linux, Mac OS, or Windows 10, this is probably named `ssh-keygen`. you can also add a comment to the key, so you remember which device it belongs to.

```
$ ssh-keygen -t ed25519 -C "my laptop"
```

follow the prompts to generate a private key. it will be saved in `/home/user/.ssh` (or your operating system's equivalent location), as well as a public key with a .pub file extension. you can add a passphrase during key generation, this is highly recommended if anyone else has access to your computer!

we'll need to get the public key, the one ending in .pub, onto the server somehow so it can recognize us. public keys don't need to be kept secret, so use any type of file transfer available to you. you could copy it to a USB drive and plug it into the server, or copy it by hand, or even send it to yourself over the public internet. once you get it to the server, create the file `~/.ssh/authorized_keys`. on a new line, **copy the full contents of the .pub file into the authorized_keys file.**

:bulb: if you need to connect from multiple devices, I recommend repeating these steps for each device, rather than copying your private key between devices. that way you don't have to worry about accidentally leaking your private key. you can add as many public keys to `authorized_keys` as you want!

at this time, try logging into the server from the newly-authorized client. it will ask for your key's passphrase if you set one, but it _won't_ ask for your account passphrase, since you already authenticated yourself by having the private key. you will still need to type your password to use sudo though, just in case.

if that went well, you can now disable password-based auth completely. as admin, open `/etc/ssh/sshd_config` and make sure this is set to 'no':

```
PasswordAuthentication no
```

save the file, and restart the ssh service:

```
# service ssh reload
```

it should now be impossible to login without an authorized key. if you want to authorize more devices, repeat these steps for each device. each device should have its own private key. never let a private key leave the device that created it. if you accidentally copy a private key, remove it from authorized_keys and create a new one to replace it.

### port forwarding

:warning: **don't do this until you've done everything else!**

it's time to make the big leap. your server is armored up and ready to face the outside world. let's open the gates. the end goal here is to forward ports 80 and 443, from the outside world to your server. if you want to log in remotely, you'll also need to forward port 22.

unfortunately, port forwarding is going to be a bit different for every router. I'll share what worked for my router, a [MikroTik](https://mikrotik.com/) running RouterOS.

- connect to the router web interface at <http://router.lan>.
- switch from Quick Set to WebFig view.
- Go to IP -> DHCP Server -> Leases.
  - find the local address assigned to teapot. this should look like 192.168.x.x, or possibly 10.0.x.x.
  - click on that address, and select 'make static'. this way, when teapot disconnects and reconnects, it will always get the same address. in my case it was 192.168.88.247.
- Go to IP -> Firewall -> NAT -> New Rule.
  - Chain: dstnat
  - Dst. Address: \<your public IP address>
  - Protocol: 6 (tcp)
  - Dst. Port: 80
  - Action: dst-nat
  - To Addresses: \<teapot's local IP address>
  - To Ports: 80
- Repeat that step for port 443.
- If you need remote login, repeat that step again for port 22. 

while we're configuring the router, we'll enable **hairpin NAT**, also known as **NAT reflection** or **NAT loopback**. without this rule, the router may get confused if we try to access teapot via its *public* address while we are inside the *local* network.

- Go to IP -> Firewall -> NAT -> New Rule (again):
  - Chain: srcnat
  - Src. Address: 192.168.88.0/24 (use your own subnet)
  - Dst. Address: \<teapot's local IP address>
  - Protocol: 6 (tcp)
  - Out. Interface List: LAN
  - Action: masquerade

you should now be able to go to http://\<your own public IP address>, and your router will forward the traffic to teapot. congratulations, your machine is now a true part of ***the internet.***

### https

todo:

- get a domain name from a service like <https://afraid.org>
- set up https with a service like LetsEncrypt
  - apt install certbot python3-certbot-apache
  - certbot certonly --apache
  - a2enmod rewrite ssl


## file sharing

another neat thing you can do with your server is use it to store stuff! there are some all-in-one solutions for this such as [NextCloud](https://nextcloud.com/), but right now that's overkill for me; I want to install simple tools to solve simple problems.

### sync

[Syncthing](https://syncthing.net/) is a simple tool for duplicating some folders across multiple devices. maybe you want all your photos to be automatically duplicated from your phone to your server, or you have some game save files that you want to be copied between two gaming pcs, or you have some other documents that you access frequently from your laptop and your desktop. Syncthing is one of those rare and beautiful gems of free software that 'just works'.

as admin, install the service:

```
# apt install syncthing
# ufw allow syncthing
```

as your normal user account, enable the service for yourself:

```
$ systemctl --user enable syncthing
$ systemctl --user start syncthing
```

that's it! Syncthing is now installed and running! you can configure Syncthing with a web app that runs on port 8384. if you're connected remotely via ssh, use this trick to get access. type the special sequence \[enter], tilde (~), C (shift+c), and you'll get a prompt like

```
ssh>
```

we'll use this prompt to set up a temporary tunnel. a **tunnel** allows you to bind a port on your client machine to a client on the server. specifically, a tunnel passes some traffic through your encrypted ssh connection, as opposed to passing it through a browser via http or https. this way you can quickly get access to an application running on your server, without exposing it to the whole internet. for this example, we'll bind the client's port 8000 to localhost:8384 on the server.

```
ssh> -L 8000:localhost:8384
```

now, open <http://localhost:8000> on your client, and you should have access to the Syncthing console running on the server!

:bulb: you can also send this command to ssh at login time. for instance:

```
$ ssh user@teapot -L 8000:localhost:8384
```

* * *

syncthing todo:

- explain my personal folder setup
- versioning options, and how this is not the same as a proper backup (but its close)

file sharing todo:

- set up samba share
- configure nfs
- [FileBrowser](https://github.com/filebrowser/filebrowser)
  - set up auth before exposing this to the internet, I think

## containers

at this point, we'll take a detour and talk about containers. everything we've done so far has involved making changes to system files. if you need to copy your data to a new system you'll have to change all those system files again, and this gets more complicated the more things are installed. thankfully, many applications can now be installed as containers.

a **container** isn't quite a virtual machine. you're not running a whole computer-inside-a-computer. it's more like a facade, a fake computer with a fake filesystem and fake network. containers don't take much memory to create, and they don't leave junk all over the filesystem when you remove them. neat!

we'll be using [Podman](https://podman.io), a container host service. if you're familiar with [Docker](https://www.docker.com), this is like that, but even *more* free.

```
# apt install podman python3-pip
# pip install "podman-compose<1.0"
```

- pip is a package manager for [Python](https://www.python.org) programs. we install pip so that we can use it to install podman-compose.
- [podman-compose](https://github.com/containers/podman-compose#podman-compose) is a very handy tool that lets you store your container instructions in a script file to use later. we'll cover this soon. I needed to specify an old version for compatibility.
- if you are on armbian, you may also need to install `uidmap` and `slirp4netns` manually. these are normally included with podman and are used for making fake users and fake networks, respectively.

we'll test Podman by running a copy of [nginx](https://nginx.org) (pronounced 'engine-x'). we'll use the image published by [Docker Hub](https://hub.docker.com). think of an **image** as a casting mold. you can't run an image directly, but you can use it to produce a filled container.

```
$ podman run --rm -p 8000:80 docker.io/library/nginx
```

- `podman run`: create a new container and start it immediately.
- `--rm`: remove the container automatically when the main program exits.
- `-p 8000:80`: connect port 8000 on the host to port 80 inside the container. we need permission to bind to ports less than 1024, since they're older and have special meanings. without that permission, we can use any port between 1024 and 65535. 8000 is an arbitrary choice, and its easy to remember.
- `docker.io/library/nginx`: this is the name of the image we're building. this has to come last, because anything that comes after the image is instructions for the program inside the container, not for Podman. in this case we're not giving any instructions after the image, because we want to run the default command, which is to immediately start nginx.

:bulb: if you get an error like "delete libpod local files to resolve", you may need to do this extra step, then try again:

```
$ sudo rm ~/.local/share/containers
```

you should now be able to point a web browser at <http://teapot.local:8000> and you will see nginx is running!

finally, we'll use podman-compose to save this setup. create a folder in `/data` for this container, and make a new file called `compose.yaml`.

contents of `/data/nginx/compose.yaml`:

```
version: '3'
services:
  nginx:
    image: docker.io/library/nginx
    ports:
    - 8000:80
```

this does the same thing as our command from before. it starts one service container, running nxing, with port 8000 on the host mapped to port 80 in the container. to run this script, type

```
$ podman-compose up -d
```

and to stop it again:

```
$ podman-compose down
```

## database

todo:

- explain why and how to host a database
- install php and mariadb
- configure phpmyadmin


## apps

todo:

- recommend some other apps like gitea, freshrss
- serve apps through apache ProxyPass
- see also [awesome self-hosted](https://github.com/awesome-selfhosted/awesome-selfhosted) and [awesome sysadmin](https://github.com/awesome-foss/awesome-sysadmin) software.

## auth

todo: 

- set up [Keycloak](https://www.keycloak.org) so you can log in through the reverse proxy.
