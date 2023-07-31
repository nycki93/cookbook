---
title: klay's simple cookbook for Linux, [v0.8.0a](https://github.com/klaymu/self-host)
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

I'll be using a [Raspberry Pi 4b] and installing [Raspberry Pi OS]. it's also known as Raspbian, since it's based on [Debian] Linux. any Debian-like OS will work for this tutorial. if the Raspberry Pi isn't available where and when you are, some good alternatives are the [Renegade] or the [ROCK64], running [armbian] Linux.

you'll also need a MicroSD card, a hard drive, and a second hard drive for backup. I recommend a 64GB MicroSD card and two 2TB hard drives. the Pi can power one hard drive via USB, but if you want to plug both in at once you'll need a powered hard drive enclosure or a powered USB hub.

you can also adapt these directions to existing hardware you may already own, like an old laptop or desktop pc. you can also rent a virtual machine from a remote datacenter! the cheapest virtual machine on [DigitalOcean] right now (as of 2023 July) costs 6 USD per month, and comes with 25GB of storage. renting a machine in a datacenter means you gget the perks of high-speed internet all day and night, which is great if you are running a game server and need a fast connection. however, you'll pay 10 USD per month for each 100GB of additional storage, so it's not great if you want to host a huge media archive.

<!-- todo: what about S3-compatible storage? -->

[Raspberry Pi 4b]: https://www.raspberrypi.com
[Debian]: https://www.debian.org/doc
[Renegade]: https://libre.computer/products/roc-rk3328-cc
[ROCK64]: https://www.pine64.org/devices/single-board-computers/rock64
[armbian]: https://www.armbian.com
[DigitalOcean]: https://www.digitalocean.com

## usernames and passwords

at some point you'll probably want to make your server available on the internet. there are bots out there that do nothing but guess random usernames and passwords all day, and they *will* find you, so you need to be prepared.

for your username, pick something short and catchy. in my experience, a typical linux username is from 3 to 8 characters long. if you have a short name like 'alice' or 'bob' you can use that. if you have a nickname online like 'azure' or 'luna' then that works too. if you have a middle name, you can use your initials, like 'jfk'. your username should be all lowercase.

for your password, the most important factor is length. I know you've been told that you need to add weird symbols and stuff in it, but that rule is for older more limited systems. it's the 64-bit era, baby! the only thing that matters is how much entropy your password has. **entropy** is basically a measure of how unlikely something is to happen twice. like if I flip ten coins and you flip ten coins and we get the same sequence, the odds of that happening are 1 in 2^10, so we say that that particular sequence of flips has 10 "bits" of entropy. it's recommended that your password have about 60 to 80 bits of entropy. yikes, that's a lot of coin flips to memorize!

luckily there's a better way. using a tool like [xkpasswd](https://xkpasswd.net/s/) or [diceware](https://theworld.com/~reinhold/diceware.html), you can convert randomness into words. using the diceware list, you can roll 25 six-sided dice to get a random 25-digit sequence, and then convert each 5 digits into a word, to get a 5-word phrase. the odds of two people getting the same 5-word phrase are 1 in 6^25, which is approximately equal to 2^64, so this password has 64 bits of entropy. that's enough to make most hackers give up and move onto an easier target. go generate a password now, and save it somewhere safe, like a password manager program, or a piece of paper tucked inside a book. don't be afraid to write things down; you can't hack a piece of paper.

## operating system

time to download and install your operating system. there are lots of guides on how to install Linux already, [here's](https://www.raspberrypi.com/documentation/computers/getting-started.html) one for Raspbian. I'll be using "Raspberry Pi OS Lite (64-Bit), with the default settings. with these settings, there is no remote login available; you will need to plug a keyboard and monitor directly into the pi. on the first boot, you'll be prompted to enter the username and password for the initial user. after that, you'll be given a login prompt. log in with the username and password you just set. some operating systems display nothing at a password prompt, not even stars. once you log in, you'll see some system information, and then a prompt that looks like

```
user@raspberrypi:~ $
```

this is a **CLI**, a command line interface. from left to right, this contains

- your name
- the machine's name
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

soon we'll unplug the keyboard and monitor from this computer, making it a 'headless' server. before we can do that we need to run a few commands as administrator, or 'root'. we'll do this with a very powerful command called `sudo`. sudo stands for 'super user do', and it means 'do the next thing as an administrator'. you can use `sudo <whatever>` for a single command, or enter interactive mode with `sudo -i`. in interactive mode, *all* your commands will be admin commands, until you say `exit`.

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

to log in remotely, go to Interface Options -> SSH.

select 'Finish'. you'll be prompted to reboot, but don't yet, we'll reboot later after installing some updates. in Debian Linux, we update packages using a tool called `apt`. `apt update` checks for updated packages, and `apt upgrade` installs them. run both these commands now, using the interactive version of `sudo`.
```
$ sudo -i
# apt update
# apt upgrade
```

finally, if you're on a Raspberry Pi, then `avahi-daemon` is installed automatically. if not, you may need to install it yourself. this program broadcasts your hostname to the network, so you can log in remotely without configuring anything on your router.

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
or
```
$ ssh user@teapot.local
```

if this works, congrats! you can now unplug the keyboard and monitor. you've created a headless server.
