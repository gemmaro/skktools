#!/bin/sh
# Known Bugs; �ù���������θ�� SPC �����äƤ��ޤ���
#
sed -f wnn2skk.sed $@ | gawk -f wnn2skk.awk -
