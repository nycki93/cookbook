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