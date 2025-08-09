#pragma once

// talk to hardware, send data
void outb(short port, char data);

// talk to hardware, recv data
char inb(short port);

