## Purpose

This program demonstrates that the high level networking API in Godot adds around 17 ms of latency (unless you are from the future and this has been fixed).
It continuously sends and receives timestamped UDP datagrams and shows the average ping time based on the latest bunch of them.

## How to use

Git clone this repository or download and unzip, and then import the project in Godot. Run two instances of it. On one, host a room.
On the other, connect to yourself by typing in localhost or 127.0.0.1.
Compare the ping you get with this program to a normal pinging utility, and notice that this program adds around 17 ms. On Windows, you can run the command line (press WIN + R, type cmd.exe, press enter) and type ping localhost. As expected when pinging yourself, you get 0 ms of latency, compared to this program's 17.
