function separator()
{
	echo 'echo "_______________________________________________________________________________________________________________________________"; echo " "';
}

watch -n 3 "                                                                                                                                   sensors | head -n -8; $(separator); acpi -a -b; $(separator); ps -Ao pcpu,comm --sort=-pcpu | head -n 9; $(separator); who"
