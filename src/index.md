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

## operating system

first, download and install your operating system. there are lots of guides on how to install Linux already, [here's](https://www.raspberrypi.com/tutorials/how-to-set-up-raspberry-pi) one for Raspbian. you may need to plug in an external keyboard and monitor while getting set up. later we can unplug those again, giving us a CLI or 'headless' server.

<!-- it's important to name drop CLI and 'headless' here so a newbie knows which version of Raspbian to download -->

if you're using Raspbian, you'll be given a default user named 'pi' with the password 'raspberry'. if you're using another Linux distribution, you'll likely be prompted to make up your own. we'll cover how to change this later.

some commands are forbidden to normal users, but your default user should have the 'sudo' permission. sudo stands for 'super user do', and it means 'do the next thing as an administrator'. you can use `sudo <whatever>` for a single command, or enter interactive mode with `sudo -i`. in interactive mode, *all* your commands will be admin commands, until you say `exit`.

:warning: **there is no undo button! if you say something with sudo, make sure you mean it!**

throughout this guide, I'll be using `$` at the start of a command if you run it as a normal user, or `#` if you run it as admin. either way, you don't actually type this symbol yourself, it should already appear on your command line.

the first thing we'll do is install system updates. 'apt' is the package manager built into Debian, it holds all your system software and lots of fun optional stuff too. 'update' looks for packages that have changed on the remote package server, and 'upgrade' installs upgraded versions of the packages you already have.
```
# apt update
# apt upgrade
```
next, we'll set your hostname. this is how you will appear to other computers on the network. for this example I'll use 'teapot'.
```
# hostnamectl set-hostname teapot
```
Raspbian comes with avahi-daemon preconfigured, which broadcasts your hostname to the network. if you are on another distribution, you can install this program with
```
# apt install avahi-daemon
```
this is a good time to reboot, to make sure the updated hostname is in use.
```
# reboot
```
after a minute, you should now be able to log in remotely from another computer, using
```
$ ssh pi@teapot
```
or
```
$ ssh pi@teapot.local
```

## usernames and passwords

at this point you should be able to log into your system from your home network, but not from the public internet. it's important that before you allow connections from strangers, you set up a good username and password. there are bots out there that do nothing but guess random usernames and passwords all day, and they *will* find you, so you need to be prepared.

for your username, pick something short and catchy. in my experience, a typical linux username is from 3 to 8 characters long. if you have a short name like 'alice' or 'bob' you can use that. if you have a nickname online like 'azure' or 'luna' then that works too. if you have a middle name, you can use your initials, like 'jfk'. your username should be all lowercase.

for your password, the most important factor is length. I know you've been told that you need to add weird symbols and stuff in it, but that rule is for older more limited systems. it's the 64-bit era, baby! the only thing that matters is how much entropy your password has. **entropy** is basically a measure of how unlikely something is to happen twice. like if I flip ten coins and you flip ten coins and we get the same sequence, the odds of that happening are 1 in 2^10, so we say that that particular sequence of flips has 10 "bits" of entropy. it's recommended that your password have about 60 to 80 bits of entropy. yikes, that's a lot of coin flips to memorize!

luckily there's a better way. using a tool like [xkpasswd](https://xkpasswd.net/s/) or [diceware](https://theworld.com/~reinhold/diceware.html), you can convert randomness into words. using the diceware list, you can roll 25 six-sided dice to get a random 25-digit sequence, and then convert each 5 digits into a word, to get a 5-word phrase. the odds of two people getting the same 5-word phrase are 1 in 6^25, which is approximately equal to 2^64, so this password has 64 bits of entropy. that's enough to make most hackers give up and move onto an easier target. go generate a password now, and save it somewhere safe, like a password manager program, or a piece of paper tucked inside a book. don't be afraid to write things down; you can't hack a piece of paper.

once you have a username and passphrase picked out, create a new user for yourself:
```
# adduser alice
```
and give them access to the sudo command:
```
# usermod -aG sudo
```
you can't remove the 'pi' user while you're still logged in as it. log out, then log back in as alice. make sure you can use sudo:
```
$ sudo -i
# exit
```
you can now remove the pi user.

*todo: test this to make sure removing the pi user doesn't break anything*
