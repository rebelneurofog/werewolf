;; TODO:
;; - File sizes (big sizes)
;; - Autocompletion of command line
;; - Possibly more information in layout
;; - Count marking files (gotta be slow or clumsy)
;; - Fix metrics updating
;; - Move to last file if current is after last (after command 'werewolf')
;; - Highlight current panel ([] around WD)
;; - Cool output for process execution
;; - Safe copy to the same inode

;;;;;;;;;;;;;;;;;
;; Requipments ;;
;;;;;;;;;;;;;;;;;
(require 'cl)
(require 'term)
(require 'files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables, faces and groups ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar ww-copy-perl-script (base64-decode-string "
CiMgQXJncyBhcmUgYWxyZWFkeSBnaXZlbiBoZXJlLCB0aGUgZW1wdHkgbGluZSBhYm92ZSBpcyBJ
TVBPUlRBTlQKJHwgPSAxOwpteSAkaHlzdGVyaWNhbCA9IDA7Cm15ICRyZW1vdmVfaW5jb21wbGV0
ZSA9IDA7Cm15ICRwcm9tcHRfaW5jb21wbGV0ZSA9IDA7Cm15ICRkaXJ0eSA9IDA7CgpteSAoJGZs
YWdzLCAkd2QsICRkZXN0aW5hdGlvbiwgQHNvdXJjZXMpID0gc3BsaXQgKCdcbicsICRhcmdzKTsK
ZGllICJXb3JraW5nIGRpcmVjdG9yeSBkb2Vzbid0IG1hdGNoIChzb21lIGJ1Zy4uLikhXG4iIGlm
ICgkRU5WeydQV0QnfSBuZSAkd2QpOwooKEBzb3VyY2VzKSA+IDApIG9yIGRpZSAiTm90IGVub3Vn
aCBwYXJhbWV0ZXJzIGdpdmVuIVxuIjsKZm9yIChteSAkaSA9IDA7ICRpIDw9ICQjc291cmNlczsg
JGkrKykgewogICAgJHNvdXJjZXNbJGldID0gJHdkLiIvIi4kc291cmNlc1skaV07Cn0KbXkgQGZs
YWdzID0gc3BsaXQgKCcsJywgJGZsYWdzKTsKZm9yZWFjaCBteSAkZmxhZyAoQGZsYWdzKSB7CiAg
ICBpZiAoJGZsYWcgZXEgJ2h5c3RlcmljYWwnKSB7CgkkaHlzdGVyaWNhbCA9IDE7CiAgICB9IGVs
c2lmICgkZmxhZyBlcSAncmVtb3ZlX2luY29tcGxldGUnKSB7CgkkcmVtb3ZlX2luY29tcGxldGUg
PSAxOwogICAgfSBlbHNpZiAoJGZsYWcgZXEgJ3Byb21wdF9pbmNvbXBsZXRlJykgewoJJHByb21w
dF9pbmNvbXBsZXRlID0gMTsKICAgIH0KfQppZiAoLWUgJGRlc3RpbmF0aW9uKSB7CiAgICBpZiAo
LWwgJGRlc3RpbmF0aW9uKSB7CglpZiAoLWQgJGRlc3RpbmF0aW9uKSB7CgkgICAgZm9yZWFjaCBt
eSAkc291cmNlIChAc291cmNlcykgewoJCW15ICgkc291cmNlbmFtZSkgPSAkc291cmNlID1+IC8o
W15cL10rKVwvKiQvOwoJCWlmIChsZW5ndGggKCRzb3VyY2VuYW1lKSkgewoJCSAgICBjb3B5X2lu
b2RlICgkZGVzdGluYXRpb24uJy8nLiRzb3VyY2VuYW1lLCAkc291cmNlKTsKCQl9IGVsc2UgewoJ
CSAgICBwcmludCBTVERFUlIgIkU6SW52YWxpZCBzb3VyY2UgbmFtZSAnJHNvdXJjZSdcbiI7CgkJ
ICAgIGlmICgkaHlzdGVyaWNhbCkgewoJCQlleGl0ICgxKQoJCSAgICB9CgkJICAgICRkaXJ0eSA9
IDE7CgkJfQoJICAgIH0KCX0gZWxzZSB7CgkgICAgcHJpbnQgU1RERVJSICJFOkRlc3RpbmF0aW9u
IGZpbGUgJyRkZXN0aW5hdGlvbicgYWxyZWFkeSBleGlzdHMgYW5kIGlzIGEgc3ltbGluayBidXQg
bm90IHBvaW50aW5nIHRvIGRpcmVjdG9yeVxuIjsKCSAgICBleGl0ICgxKTsKCX0KICAgIH0gZWxz
aWYgKC1kICRkZXN0aW5hdGlvbikgewoJZm9yZWFjaCBteSAkc291cmNlIChAc291cmNlcykgewoJ
ICAgIG15ICgkc291cmNlbmFtZSkgPSAkc291cmNlID1+IC8oW15cL10rKVwvKiQvOwoJICAgIGlm
IChsZW5ndGggKCRzb3VyY2VuYW1lKSkgewoJCWNvcHlfaW5vZGUgKCRkZXN0aW5hdGlvbi4nLycu
JHNvdXJjZW5hbWUsICRzb3VyY2UpOwoJICAgIH0gZWxzZSB7CgkJcHJpbnQgU1RERVJSICJFOklu
dmFsaWQgc291cmNlIG5hbWUgJyRzb3VyY2UnXG4iOwoJCWlmICgkaHlzdGVyaWNhbCkgewoJCSAg
ICBleGl0ICgxKQoJCX0KCQkkZGlydHkgPSAxOwoJICAgIH0KCX0KICAgIH0gZWxzaWYgKC1mICRk
ZXN0aW5hdGlvbikgewoJaWYgKCgoQHNvdXJjZXMpID09IDEpIGFuZCAoISgtbCAkc291cmNlc1sw
XSkgYW5kICgtZiAkc291cmNlc1swXSkpKSB7CgkgICAgaWYgKCFjb3B5X3JlZ3VsYXIgKCRkZXN0
aW5hdGlvbiwgJHNvdXJjZXNbMF0pKSB7CgkJZXhpdCAoMSk7CgkgICAgfQoJfSBlbHNlIHsKCSAg
ICBwcmludCBTVERFUlIgIkU6RGVzdGluYXRpb24gZmlsZSBleGlzdHMgYnV0IGlzbid0IGRpcmVj
dG9yeSBvciBzeW1saW5rIHRvIGRpcmVjdG9yeVxuIjsKCSAgICBleGl0ICgxKTsKCX0KICAgIH0g
ZWxzZSB7CglwcmludCBTVERFUlIgIkU6RGVzdGluYXRpb24gZmlsZSBleGlzdHMgYnV0IGlzbid0
IHJlZ3VsYXJ5IGZpbGUsIGRpcmVjdG9yeSBvciBzeW1saW5rIHRvIGRpcmVjdG9yeVxuIjsKCWV4
aXQgKDEpOwogICAgfQp9IGVsc2UgewogICAgaWYgKChAc291cmNlcykgPT0gMSkgewoJaWYgKCFj
b3B5X2lub2RlICgkZGVzdGluYXRpb24sICRzb3VyY2VzWzBdKSkgewoJICAgIGV4aXQgKDEpOwoJ
fQogICAgfSBlbHNlIHsKCXByaW50IFNUREVSUiAiRTpObyBkZXN0aW5hdGlvbiBkaXJlY3Rvcnkg
ZXhpc3RzIGJ1dCBtdWx0aXBsZSBzb3VyY2UgZmlsZXMgZ2l2ZW5cbiI7CglleGl0ICgxKTsKICAg
IH0KfQoKc3ViIGNoZWNrX2RpcmVjdG9yeSB7CiAgICBteSAoJHBhdGgpID0gQF87CiAgICBpZiAo
IW1rZGlyICgkcGF0aCkgJiYgKCEkIXtFRVhJU1R9IHx8ICEoLWQgJHBhdGgpKSkgewoJcHJpbnQg
U1RERVJSICJFOkZhaWxlZCB0byBjcmVhdGUgZGlyZWN0b3J5ICckcGF0aCc6ICQhXG4iOwoJaWYg
KCRoeXN0ZXJpY2FsKSB7CgkgICAgZXhpdCAoMSkKCX0KCSRkaXJ0eSA9IDE7CglyZXR1cm4gMDsK
ICAgIH0KICAgIGlmICghY2htb2QgKDA3NzcgJn4gdW1hc2sgKCksICRwYXRoKSkgewoJcHJpbnQg
U1RERVJSICJFOkZhaWxlZCB0byBzZXQgcGVybWlzc2lvbnMgdG8gJyRwYXRoJzogJCFcbiI7Cglp
ZiAoJGh5c3RlcmljYWwpIHsKCSAgICBleGl0ICgxKTsKCX0KCSRkaXJ0eSA9IDE7CiAgICB9CiAg
ICByZXR1cm4gMTsKfQpzdWIgY29weV9yZWd1bGFyIHsKICAgIG15ICgkZGVzdGluYXRpb24sICRz
b3VyY2UpID0gQF87CiAgICBteSAoJGRmaCwgJHNmaCwgJGJ1ZmZlciwgJHJldCwgJHBlcmNlbnQs
ICRyZWFkLCAkc2l6ZSk7CiAgICBteSBAc3RhdCA9IHN0YXQgKCRzb3VyY2UpOwogICAgaWYgKCFA
c3RhdCkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBzdGF0ICckc291cmNlJyBmaWxlXG4i
OwoJaWYgKCRoeXN0ZXJpY2FsKSB7CgkgICAgZXhpdCAoMSkKCX0KCSRkaXJ0eSA9IDE7CglyZXR1
cm4gMDsKICAgIH0KICAgICRzaXplID0gJHN0YXRbN107CiAgICBpZiAoIW9wZW4gKCRkZmgsICI+
IiwgJGRlc3RpbmF0aW9uKSkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBvcGVuIGRlc3Rp
bmF0aW9uIGZpbGUgJyRkZXN0aW5hdGlvbic6ICQhXG4iOwoJaWYgKCRoeXN0ZXJpY2FsKSB7Cgkg
ICAgZXhpdCAoMSkKCX0KCSRkaXJ0eSA9IDE7CglyZXR1cm4gMDsKICAgIH0KICAgIGlmICghb3Bl
biAoJHNmaCwgIjwiLCAkc291cmNlKSkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBvcGVu
IHNvdXJjZSBmaWxlICckc291cmNlJzogJCFcbiI7CglpZiAoJGh5c3RlcmljYWwpIHsKCSAgICBl
eGl0ICgxKQoJfQoJJGRpcnR5ID0gMTsKCXJldHVybiAwOwogICAgfQogICAgJHJlYWQgPSAwOwog
ICAgJHBlcmNlbnQgPSAwOwogICAgcHJpbnQgU1RERVJSICgiRjokZGVzdGluYXRpb246JHNvdXJj
ZVxuIik7CiAgICBwcmludCBTVERFUlIgKCJwOjBcbiIpOwogICAgd2hpbGUgKCgkcmV0ID0gcmVh
ZCAoJHNmaCwgJGJ1ZmZlciwgMTA0ODU3NikpKSB7CglpZiAoIXByaW50ICRkZmggKCRidWZmZXIp
KSB7CgkgICAgcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byB3cml0ZSB0byBkZXN0aW5hdGlvbiBm
aWxlIGZpbGUgJyRkZXN0aW5hdGlvbic6ICQhXG4iOwoJICAgIGlmICgkaHlzdGVyaWNhbCkgewoJ
CWV4aXQgKDEpCgkgICAgfQoJICAgICRkaXJ0eSA9IDE7CgkgICAgcmV0dXJuIDA7Cgl9CgkkcmVh
ZCArPSAkcmV0OwoJbXkgJG5ld19wZXJjZW50ID0gJHNpemUgPyBpbnQgKCRyZWFkKjEwMC8kc2l6
ZSkgOiAxMDA7CglpZiAoJG5ld19wZXJjZW50ICE9ICRwZXJjZW50KSB7CgkgICAgJHBlcmNlbnQg
PSAkbmV3X3BlcmNlbnQ7CgkgICAgcHJpbnRmIFNUREVSUiAoInA6JWRcbiIsICRwZXJjZW50KTsK
CX0KICAgIH0KICAgIHByaW50IFNUREVSUiAoInA6MTAwXG4iKTsKICAgIGlmICgkcmV0ICE9IDAp
IHsKCXByaW50IFNUREVSUiAiRTpGYWlsZWQgdG8gcmVhZCBmcm9tIHNvdXJjZSBmaWxlICckc291
cmNlJzogJCFcbiI7CglpZiAoJGh5c3RlcmljYWwpIHsKCSAgICBleGl0ICgxKQoJfQoJJGRpcnR5
ID0gMTsKCXJldHVybiAwOwogICAgfQogICAgY2xvc2UgKCRzZmgpOwogICAgbXkgJHBlcm0gPSAo
LXggJHNvdXJjZSkgPyAoMDc3NyAmfiB1bWFzayAoKSkgOiAoMDY2NiAmfiB1bWFzayAoKSk7CiAg
ICBpZiAoIWNobW9kICgkcGVybSwgJGRlc3RpbmF0aW9uKSkgewoJcHJpbnQgU1RERVJSICJFOkZh
aWxlZCB0byBzZXQgcGVybWlzc2lvbnMgdG8gJyRkZXN0aW5hdGlvbic6ICQhXG4iOwoJaWYgKCRo
eXN0ZXJpY2FsKSB7CgkgICAgZXhpdCAoMSkKCX0KCSRkaXJ0eSA9IDE7CiAgICB9CiAgICByZXR1
cm4gMTsKfQpzdWIgY29weV9zeW1saW5rIHsKICAgIG15ICgkZGVzdGluYXRpb24sICRzb3VyY2Up
ID0gQF87CiAgICBteSAkbGlua19uYW1lID0gcmVhZGxpbmsgKCRzb3VyY2UpOwogICAgaWYgKCFk
ZWZpbmVkICgkbGlua19uYW1lKSkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byByZWFkIHN5
bWxpbmsgJyRzb3VyY2UnOiAkIVxuIjsKCWlmICgkaHlzdGVyaWNhbCkgewoJICAgIGV4aXQgKDEp
Cgl9CgkkZGlydHkgPSAxOwoJcmV0dXJuIDA7CiAgICB9CiAgICBpZiAoIXN5bWxpbmsgKCRsaW5r
X25hbWUsICRkZXN0aW5hdGlvbikpIHsKCXByaW50IFNUREVSUiAiRTpGYWlsZWQgdG8gY3JlYXRl
IHN5bWxpbmsgJyRzb3VyY2UnOiAkIVxuIjsKCWlmICgkaHlzdGVyaWNhbCkgewoJICAgIGV4aXQg
KDEpCgl9CgkkZGlydHkgPSAxOwoJcmV0dXJuIDA7CiAgICB9CiAgICBwcmludCBTVERFUlIgIkw6
JGRlc3RpbmF0aW9uOiRzb3VyY2VcbiI7CiAgICByZXR1cm4gMTsKfQpzdWIgY29weV9zcGVjaWFs
IHsKICAgIG15ICgkZGVzdGluYXRpb24sICRzb3VyY2UpID0gQF87CiAgICBpZiAoLWMgJHNvdXJj
ZSkgewoJbXkgKEBzdGF0KSA9IHN0YXQgKCRzb3VyY2UpOwoJaWYgKCFAc3RhdCkgewoJICAgIHBy
aW50IFNUREVSUiAiRTpGYWlsZWQgdG8gc3RhdCBjaGFyYWN0ZXIgZmlsZSAnJHNvdXJjZSdcbiI7
CgkgICAgaWYgKCRoeXN0ZXJpY2FsKSB7CgkJZXhpdCAoMSkKCSAgICB9CgkgICAgJGRpcnR5ID0g
MTsKCSAgICByZXR1cm4gMDsKCX0KCW15ICgkbWFqb3IsICRtaW5vcikgPSAoKCRzdGF0WzZdID4+
IDgpICYgMHhmZiwgJHN0YXRbNl0gJiAweGZmKTsKCWlmIChzeXN0ZW0gKCdta25vZCcsICRkZXN0
aW5hdGlvbiwgJ2MnLCAiJG1ham9yIiwgIiRtaW5vciIpKSB7CgkgICAgaWYgKCQ/ID09IC0xKSB7
CgkJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBleGVjdXRlICdta25vZCcgZm9yIGNyZWF0aW5n
IGNoYXJhY3RlciBkZXZpY2UgJyRzb3VyY2UnOiAkIVxuIjsKCSAgICB9IGVsc2lmICgkPyAmIDEy
NykgewoJCXByaW50IFNUREVSUiAiRTpGYWlsZWQgdG8gY3JlYXRlIGNoYXJhY3RlciBkZXZpY2Ug
JyRzb3VyY2UnOiAnbWtub2QnIGRpZWQgd2l0aCBzaWduYWwgIi4oJD8gJiAxMjcpLiJcbiI7Cgkg
ICAgfSBlbHNlIHsKCQlwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIGNyZWF0ZSBjaGFyYWN0ZXIg
ZGV2aWNlICckc291cmNlJzogJ21rbm9kJyBleGl0ZWQgd2l0aCB2YWx1ZSAiLigkPyA+PiA4KS4i
XG4iOwoJICAgIH0KCSAgICBpZiAoJGh5c3RlcmljYWwpIHsKCQlleGl0ICgxKQoJICAgIH0KCSAg
ICAkZGlydHkgPSAxOwoJICAgIHJldHVybiAwOwoJfQoJcHJpbnQgU1RERVJSICJDOiRkZXN0aW5h
dGlvbjokc291cmNlXG4iOwogICAgfSBlbHNpZiAoLWIgJHNvdXJjZSkgewoJbXkgKEBzdGF0KSA9
IHN0YXQgKCRzb3VyY2UpOwoJaWYgKCFAc3RhdCkgewoJICAgIHByaW50IFNUREVSUiAiRTpGYWls
ZWQgdG8gc3RhdCBibG9jayBmaWxlICckc291cmNlJ1xuIjsKCSAgICBpZiAoJGh5c3RlcmljYWwp
IHsKCQlleGl0ICgxKQoJICAgIH0KCSAgICAkZGlydHkgPSAxOwoJICAgIHJldHVybiAwOwoJfQoJ
bXkgKCRtYWpvciwgJG1pbm9yKSA9ICgoJHN0YXRbNl0gPj4gOCkgJiAweGZmLCAkc3RhdFs2XSAm
IDB4ZmYpOwoJaWYgKHN5c3RlbSAoJ21rbm9kJywgJGRlc3RpbmF0aW9uLCAnYicsICIkbWFqb3Ii
LCAiJG1pbm9yIikpIHsKCSAgICBpZiAoJD8gPT0gLTEpIHsKCQlwcmludCBTVERFUlIgIkU6RmFp
bGVkIHRvIGV4ZWN1dGUgJ21rbm9kJyBmb3IgY3JlYXRpbmcgYmxvY2sgZGV2aWNlICckc291cmNl
JzogJCFcbiI7CgkgICAgfSBlbHNpZiAoJD8gJiAxMjcpIHsKCQlwcmludCBTVERFUlIgIkU6RmFp
bGVkIHRvIGNyZWF0ZSBibG9jayBkZXZpY2UgJyRzb3VyY2UnOiAnbWtub2QnIGRpZWQgd2l0aCBz
aWduYWwgIi4oJD8gJiAxMjcpLiJcbiI7CgkgICAgfSBlbHNlIHsKCQlwcmludCBTVERFUlIgIkU6
RmFpbGVkIHRvIGNyZWF0ZSBibG9jayBkZXZpY2UgJyRzb3VyY2UnOiAnbWtub2QnIGV4aXRlZCB3
aXRoIHZhbHVlICIuKCQ/ID4+IDgpLiJcbiI7CgkgICAgfQoJICAgIGlmICgkaHlzdGVyaWNhbCkg
ewoJCWV4aXQgKDEpCgkgICAgfQoJICAgICRkaXJ0eSA9IDE7CgkgICAgcmV0dXJuIDA7Cgl9Cglw
cmludCBTVERFUlIgIkI6JGRlc3RpbmF0aW9uOiRzb3VyY2VcbiI7CiAgICB9IGVsc2lmICgtcCAk
c291cmNlKSB7CglpZiAoc3lzdGVtICgnbWtub2QnLCAkZGVzdGluYXRpb24sICdwJykpIHsKCSAg
ICBpZiAoJD8gPT0gLTEpIHsKCQlwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIGV4ZWN1dGUgJ21r
bm9kJyBmb3IgY3JlYXRpbmcgYmxvY2sgZGV2aWNlICckc291cmNlJzogJCFcbiI7CgkgICAgfSBl
bHNpZiAoJD8gJiAxMjcpIHsKCQlwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIGNyZWF0ZSBibG9j
ayBkZXZpY2UgJyRzb3VyY2UnOiAnbWtub2QnIGRpZWQgd2l0aCBzaWduYWwgIi4oJD8gJiAxMjcp
LiJcbiI7CgkgICAgfSBlbHNlIHsKCQlwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIGNyZWF0ZSBi
bG9jayBkZXZpY2UgJyRzb3VyY2UnOiAnbWtub2QnIGV4aXRlZCB3aXRoIHZhbHVlICIuKCQ/ID4+
IDgpLiJcbiI7CgkgICAgfQoJICAgIGlmICgkaHlzdGVyaWNhbCkgewoJCWV4aXQgKDEpCgkgICAg
fQoJICAgICRkaXJ0eSA9IDE7CgkgICAgcmV0dXJuIDA7Cgl9CglwcmludCBTVERFUlIgIlA6JGRl
c3RpbmF0aW9uOiRzb3VyY2VcbiI7CiAgICB9IGVsc2UgewoJcHJpbnQgU1RERVJSICJFOlVua25v
d24gZmlsZSB0eXBlIG9mICckc291cmNlJ1xuIjsKCWlmICgkaHlzdGVyaWNhbCkgewoJICAgIGV4
aXQgKDEpCgl9CgkkZGlydHkgPSAxOwoJcmV0dXJuIDA7CiAgICB9CiAgICByZXR1cm4gMTsKfQpz
dWIgY29weV9kaXJlY3RvcnkgewogICAgbXkgKCRkZXN0aW5hdGlvbiwgJHNvdXJjZSkgPSBAXzsK
ICAgIG15ICRzb3VyY2VkaXI7CiAgICBpZiAoIW9wZW5kaXIgKCRzb3VyY2VkaXIsICRzb3VyY2Up
KSB7CglwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIG9wZW4gZGlyZWN0b3J5ICckc291cmNlJzog
JCFcbiI7CglpZiAoJGh5c3RlcmljYWwpIHsKCSAgICBleGl0ICgxKQoJfQoJJGRpcnR5ID0gMTsK
CXJldHVybiAwOwogICAgfQogICAgcmV0dXJuIDAgdW5sZXNzIGNoZWNrX2RpcmVjdG9yeSAoJGRl
c3RpbmF0aW9uKTsKICAgIHByaW50IFNUREVSUiAiRDokZGVzdGluYXRpb246JHNvdXJjZVxuIjsK
ICAgIHdoaWxlIChteSAkZmlsZSA9IHJlYWRkaXIgKCRzb3VyY2VkaXIpKSB7CgluZXh0IGlmICRm
aWxlIGVxICcuJzsKCW5leHQgaWYgJGZpbGUgZXEgJy4uJzsKCW15ICgkc291cmNlX2Z1bGwsICRk
ZXN0aW5hdGlvbl9mdWxsKSA9ICgkc291cmNlLicvJy4kZmlsZSwgJGRlc3RpbmF0aW9uLicvJy4k
ZmlsZSk7CglpZiAoIWNvcHlfaW5vZGUgKCRkZXN0aW5hdGlvbl9mdWxsLCAkc291cmNlX2Z1bGwp
KSB7CgkgICAgaWYgKCRoeXN0ZXJpY2FsKSB7CgkJZXhpdCAoMSkKCSAgICB9Cgl9CiAgICB9CiAg
ICByZXR1cm4gMTsKfQpzdWIgY29weV9pbm9kZSB7CiAgICBteSAoJGRlc3RpbmF0aW9uLCAkc291
cmNlKSA9IEBfOwogICAgaWYgKC1sICRzb3VyY2UpIHsKCXJldHVybiBjb3B5X3N5bWxpbmsgKCRk
ZXN0aW5hdGlvbiwgJHNvdXJjZSk7CiAgICB9IGVsc2lmICgtZCAkc291cmNlKSB7CglyZXR1cm4g
Y29weV9kaXJlY3RvcnkgKCRkZXN0aW5hdGlvbiwgJHNvdXJjZSk7CiAgICB9IGVsc2lmICgtZiAk
c291cmNlKSB7CglyZXR1cm4gY29weV9yZWd1bGFyICgkZGVzdGluYXRpb24sICRzb3VyY2UpOwog
ICAgfSBlbHNlIHsKCXJldHVybiBjb3B5X3NwZWNpYWwgKCRkZXN0aW5hdGlvbiwgJHNvdXJjZSk7
CiAgICB9Cn0KCmlmICgkZGlydHkpIHsKICAgIGV4aXQgMTsKfQoKZXhpdCAwOwo=
")
  "Copy Perl script")

(defvar ww-rename-perl-script (base64-decode-string "
CiMgQXJncyBhcmUgYWxyZWFkeSBnaXZlbiBoZXJlLCB0aGUgZW1wdHkgbGluZSBhYm92ZSBpcyBJ
TVBPUlRBTlQKJHwgPSAxOwpteSAkaHlzdGVyaWNhbCA9IDA7Cm15ICRyZW1vdmVfaW5jb21wbGV0
ZSA9IDA7Cm15ICRwcm9tcHRfaW5jb21wbGV0ZSA9IDA7Cm15ICRkaXJ0eSA9IDA7CgpteSAoJGZs
YWdzLCAkd2QsICRkZXN0aW5hdGlvbiwgQHNvdXJjZXMpID0gc3BsaXQgKCdcbicsICRhcmdzKTsK
ZGllICJXb3JraW5nIGRpcmVjdG9yeSBkb2Vzbid0IG1hdGNoIChzb21lIGJ1Zy4uLikhXG4iIGlm
ICgkRU5WeydQV0QnfSBuZSAkd2QpOwooKEBzb3VyY2VzKSA+IDApIG9yIGRpZSAiTm90IGVub3Vn
aCBwYXJhbWV0ZXJzIGdpdmVuIVxuIjsKZm9yIChteSAkaSA9IDA7ICRpIDw9ICQjc291cmNlczsg
JGkrKykgewogICAgJHNvdXJjZXNbJGldID0gJHdkLiIvIi4kc291cmNlc1skaV07Cn0KbXkgQGZs
YWdzID0gc3BsaXQgKCcsJywgJGZsYWdzKTsKZm9yZWFjaCBteSAkZmxhZyAoQGZsYWdzKSB7CiAg
ICBpZiAoJGZsYWcgZXEgJ2h5c3RlcmljYWwnKSB7CgkkaHlzdGVyaWNhbCA9IDE7CiAgICB9IGVs
c2lmICgkZmxhZyBlcSAncmVtb3ZlX2luY29tcGxldGUnKSB7CgkkcmVtb3ZlX2luY29tcGxldGUg
PSAxOwogICAgfSBlbHNpZiAoJGZsYWcgZXEgJ3Byb21wdF9pbmNvbXBsZXRlJykgewoJJHByb21w
dF9pbmNvbXBsZXRlID0gMTsKICAgIH0KfQppZiAoLWUgJGRlc3RpbmF0aW9uKSB7CiAgICBpZiAo
LWwgJGRlc3RpbmF0aW9uKSB7CglpZiAoLWQgJGRlc3RpbmF0aW9uKSB7CgkgICAgZm9yZWFjaCBt
eSAkc291cmNlIChAc291cmNlcykgewoJCW15ICgkc291cmNlbmFtZSkgPSAkc291cmNlID1+IC8o
W15cL10rKVwvKiQvOwoJCWlmIChsZW5ndGggKCRzb3VyY2VuYW1lKSkgewoJCSAgICByZW5hbWVf
aW5vZGUgKCRkZXN0aW5hdGlvbi4nLycuJHNvdXJjZW5hbWUsICRzb3VyY2UpOwoJCX0gZWxzZSB7
CgkJICAgIHByaW50IFNUREVSUiAiRTpJbnZhbGlkIHNvdXJjZSBuYW1lICckc291cmNlJ1xuIjsK
CQkgICAgaWYgKCRoeXN0ZXJpY2FsKSB7CgkJCWV4aXQgKDEpCgkJICAgIH0KCQkgICAgJGRpcnR5
ID0gMTsKCQl9CgkgICAgfQoJfSBlbHNlIHsKCSAgICBwcmludCBTVERFUlIgIkU6RGVzdGluYXRp
b24gZmlsZSAnJGRlc3RpbmF0aW9uJyBhbHJlYWR5IGV4aXN0cyBhbmQgaXMgYSBzeW1saW5rIGJ1
dCBub3QgcG9pbnRpbmcgdG8gZGlyZWN0b3J5XG4iOwoJICAgIGV4aXQgKDEpOwoJfQogICAgfSBl
bHNpZiAoLWQgJGRlc3RpbmF0aW9uKSB7Cglmb3JlYWNoIG15ICRzb3VyY2UgKEBzb3VyY2VzKSB7
CgkgICAgbXkgKCRzb3VyY2VuYW1lKSA9ICRzb3VyY2UgPX4gLyhbXlwvXSspXC8qJC87CgkgICAg
aWYgKGxlbmd0aCAoJHNvdXJjZW5hbWUpKSB7CgkJcmVuYW1lX2lub2RlICgkZGVzdGluYXRpb24u
Jy8nLiRzb3VyY2VuYW1lLCAkc291cmNlKTsKCSAgICB9IGVsc2UgewoJCXByaW50IFNUREVSUiAi
RTpJbnZhbGlkIHNvdXJjZSBuYW1lICckc291cmNlJ1xuIjsKCQlpZiAoJGh5c3RlcmljYWwpIHsK
CQkgICAgZXhpdCAoMSkKCQl9CgkJJGRpcnR5ID0gMTsKCSAgICB9Cgl9CiAgICB9IGVsc2lmICgt
ZiAkZGVzdGluYXRpb24pIHsKCXByaW50IFNUREVSUiAiRTpEZXN0aW5hdGlvbiBmaWxlIGV4aXN0
cyBidXQgaXNuJ3QgZGlyZWN0b3J5IG9yIHN5bWxpbmsgdG8gZGlyZWN0b3J5XG4iOwoJZXhpdCAo
MSk7CiAgICB9IGVsc2UgewoJcHJpbnQgU1RERVJSICJFOkRlc3RpbmF0aW9uIGZpbGUgZXhpc3Rz
IGJ1dCBpc24ndCByZWd1bGFyeSBmaWxlLCBkaXJlY3Rvcnkgb3Igc3ltbGluayB0byBkaXJlY3Rv
cnlcbiI7CglleGl0ICgxKTsKICAgIH0KfSBlbHNlIHsKICAgIGlmICgoQHNvdXJjZXMpID09IDEp
IHsKCWlmICghcmVuYW1lX2lub2RlICgkZGVzdGluYXRpb24sICRzb3VyY2VzWzBdKSkgewoJICAg
IGV4aXQgKDEpOwoJfQogICAgfSBlbHNlIHsKCXByaW50IFNUREVSUiAiRTpObyBkZXN0aW5hdGlv
biBkaXJlY3RvcnkgZXhpc3RzIGJ1dCBtdWx0aXBsZSBzb3VyY2UgZmlsZXMgZ2l2ZW5cbiI7Cgll
eGl0ICgxKTsKICAgIH0KfQoKc3ViIGNoZWNrX2RpcmVjdG9yeSB7CiAgICBteSAoJHBhdGgpID0g
QF87CiAgICBpZiAoIW1rZGlyICgkcGF0aCkgJiYgKCEkIXtFRVhJU1R9IHx8ICEoLWQgJHBhdGgp
KSkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBjcmVhdGUgZGlyZWN0b3J5ICckcGF0aCc6
ICQhXG4iOwoJaWYgKCRoeXN0ZXJpY2FsKSB7CgkgICAgZXhpdCAoMSkKCX0KCSRkaXJ0eSA9IDE7
CglyZXR1cm4gMDsKICAgIH0KICAgIGlmICghY2htb2QgKDA3NzcgJn4gdW1hc2sgKCksICRwYXRo
KSkgewoJcHJpbnQgU1RERVJSICJFOkZhaWxlZCB0byBzZXQgcGVybWlzc2lvbnMgdG8gJyRwYXRo
JzogJCFcbiI7CglpZiAoJGh5c3RlcmljYWwpIHsKCSAgICBleGl0ICgxKTsKCX0KCSRkaXJ0eSA9
IDE7CiAgICB9CiAgICByZXR1cm4gMTsKfQpzdWIgcmVuYW1lX3JlZ3VsYXIgewogICAgbXkgKCRk
ZXN0aW5hdGlvbiwgJHNvdXJjZSkgPSBAXzsKICAgIGlmICghcmVuYW1lICgkc291cmNlLCAkZGVz
dGluYXRpb24pKSB7CglwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIHJlbmFtZSByZWd1bGFyIGZp
bGUgJyRzb3VyY2UnOiAkIVxuIjsKCWlmICgkaHlzdGVyaWNhbCkgewoJICAgIGV4aXQgKDEpCgl9
CgkkZGlydHkgPSAxOwoJcmV0dXJuIDA7CiAgICB9CiAgICBwcmludCBTVERFUlIgKCJGOiRkZXN0
aW5hdGlvbjokc291cmNlXG4iKTsKICAgIHByaW50IFNUREVSUiAoInA6MTAwXG4iKTsKICAgIHJl
dHVybiAxOwp9CnN1YiByZW5hbWVfc3ltbGluayB7CiAgICBteSAoJGRlc3RpbmF0aW9uLCAkc291
cmNlKSA9IEBfOwogICAgaWYgKCFyZW5hbWUgKCRzb3VyY2UsICRkZXN0aW5hdGlvbikpIHsKCXBy
aW50IFNUREVSUiAiRTpGYWlsZWQgdG8gcmVuYW1lIHN5bWxpbmsgJyRzb3VyY2UnOiAkIVxuIjsK
CWlmICgkaHlzdGVyaWNhbCkgewoJICAgIGV4aXQgKDEpCgl9CgkkZGlydHkgPSAxOwoJcmV0dXJu
IDA7CiAgICB9CiAgICBwcmludCBTVERFUlIgIkw6JGRlc3RpbmF0aW9uOiRzb3VyY2VcbiI7CiAg
ICByZXR1cm4gMTsKfQpzdWIgcmVuYW1lX3NwZWNpYWwgewogICAgbXkgKCRkZXN0aW5hdGlvbiwg
JHNvdXJjZSkgPSBAXzsKICAgIGlmICgtYyAkc291cmNlKSB7CglpZiAoIXJlbmFtZSAoJHNvdXJj
ZSwgJGRlc3RpbmF0aW9uKSkgewoJICAgIHByaW50IFNUREVSUiAiRTpGYWlsZWQgdG8gcmVuYW1l
IGNoYXJhY3RlciBmaWxlICckc291cmNlJzogJCFcbiI7CgkgICAgaWYgKCRoeXN0ZXJpY2FsKSB7
CgkJZXhpdCAoMSkKCSAgICB9CgkgICAgJGRpcnR5ID0gMTsKCSAgICByZXR1cm4gMDsKCX0KCXBy
aW50IFNUREVSUiAiQzokZGVzdGluYXRpb246JHNvdXJjZVxuIjsKICAgIH0gZWxzaWYgKC1iICRz
b3VyY2UpIHsKCWlmICghcmVuYW1lICgkc291cmNlLCAkZGVzdGluYXRpb24pKSB7CgkgICAgcHJp
bnQgU1RERVJSICJFOkZhaWxlZCB0byByZW5hbWUgYmxvY2sgZmlsZSAnJHNvdXJjZSc6ICQhXG4i
OwoJICAgIGlmICgkaHlzdGVyaWNhbCkgewoJCWV4aXQgKDEpCgkgICAgfQoJICAgICRkaXJ0eSA9
IDE7CgkgICAgcmV0dXJuIDA7Cgl9CglwcmludCBTVERFUlIgIkI6JGRlc3RpbmF0aW9uOiRzb3Vy
Y2VcbiI7CiAgICB9IGVsc2lmICgtcCAkc291cmNlKSB7CglpZiAoIXJlbmFtZSAoJHNvdXJjZSwg
JGRlc3RpbmF0aW9uKSkgewoJICAgIHByaW50IFNUREVSUiAiRTpGYWlsZWQgdG8gcmVuYW1lIHBp
cGUgJyRzb3VyY2UnOiAkIVxuIjsKCSAgICBpZiAoJGh5c3RlcmljYWwpIHsKCQlleGl0ICgxKQoJ
ICAgIH0KCSAgICAkZGlydHkgPSAxOwoJICAgIHJldHVybiAwOwoJfQoJcHJpbnQgU1RERVJSICJQ
OiRkZXN0aW5hdGlvbjokc291cmNlXG4iOwogICAgfSBlbHNlIHsKCXByaW50IFNUREVSUiAiRTpV
bmtub3duIGZpbGUgdHlwZSBvZiAnJHNvdXJjZSdcbiI7CglpZiAoJGh5c3RlcmljYWwpIHsKCSAg
ICBleGl0ICgxKQoJfQoJJGRpcnR5ID0gMTsKCXJldHVybiAwOwogICAgfQogICAgcmV0dXJuIDE7
Cn0Kc3ViIHJlbmFtZV9kaXJlY3RvcnkgewogICAgbXkgKCRkZXN0aW5hdGlvbiwgJHNvdXJjZSkg
PSBAXzsKICAgIGlmICghcmVuYW1lICgkc291cmNlLCAkZGVzdGluYXRpb24pKSB7CglwcmludCBT
VERFUlIgIkU6RmFpbGVkIHRvIHJlbmFtZSBkaXJlY3RvcnkgJyRzb3VyY2UnOiAkIVxuIjsKCWlm
ICgkaHlzdGVyaWNhbCkgewoJICAgIGV4aXQgKDEpCgl9CgkkZGlydHkgPSAxOwoJcmV0dXJuIDA7
CiAgICB9CiAgICBwcmludCBTVERFUlIgIkQ6JGRlc3RpbmF0aW9uOiRzb3VyY2VcbiI7CiAgICBy
ZXR1cm4gMTsKfQpzdWIgcmVuYW1lX2lub2RlIHsKICAgIG15ICgkZGVzdGluYXRpb24sICRzb3Vy
Y2UpID0gQF87CiAgICBpZiAoLWwgJHNvdXJjZSkgewoJcmV0dXJuIHJlbmFtZV9zeW1saW5rICgk
ZGVzdGluYXRpb24sICRzb3VyY2UpOwogICAgfSBlbHNpZiAoLWQgJHNvdXJjZSkgewoJcmV0dXJu
IHJlbmFtZV9kaXJlY3RvcnkgKCRkZXN0aW5hdGlvbiwgJHNvdXJjZSk7CiAgICB9IGVsc2lmICgt
ZiAkc291cmNlKSB7CglyZXR1cm4gcmVuYW1lX3JlZ3VsYXIgKCRkZXN0aW5hdGlvbiwgJHNvdXJj
ZSk7CiAgICB9IGVsc2UgewoJcmV0dXJuIHJlbmFtZV9zcGVjaWFsICgkZGVzdGluYXRpb24sICRz
b3VyY2UpOwogICAgfQp9CgppZiAoJGRpcnR5KSB7CiAgICBleGl0IDE7Cn0KCmV4aXQgMDsK
")
  "Rename Perl script")

(defvar ww-remove-perl-script (base64-decode-string "
CiMgQXJncyBhcmUgYWxyZWFkeSBnaXZlbiBoZXJlLCB0aGUgZW1wdHkgbGluZSBhYm92ZSBpcyBJ
TVBPUlRBTlQKJHwgPSAxOyAgICAKbXkgJGh5c3RlcmljYWwgPSAwOwpteSAkZGlydHkgPSAwOwoK
bXkgKCRmbGFncywgJHdkLCBAbGlzdCkgPSBzcGxpdCAoJ1xuJywgJGFyZ3MpOwpkaWUgIldvcmtp
bmcgZGlyZWN0b3J5IGRvZXNuJ3QgbWF0Y2ggKHNvbWUgYnVnLi4uKSFcclxuIiBpZiAoJEVOVnsn
UFdEJ30gbmUgJHdkKTsKKChAbGlzdCkgPiAwKSBvciBkaWUgIk5vdCBlbm91Z2ggcGFyYW1ldGVy
cyBnaXZlbiFcclxuIjsKbXkgQGZsYWdzID0gc3BsaXQgKCcsJywgJGZsYWdzKTsKZm9yZWFjaCBt
eSAkZmxhZyAoQGZsYWdzKSB7CiAgICBpZiAoJGZsYWcgZXEgJ2h5c3RlcmljYWwnKSB7CgkkaHlz
dGVyaWNhbCA9IDE7CiAgICB9Cn0KZm9yIG15ICRub2RlIChAbGlzdCkgewogICAgcmVtb3ZlX3Jl
Y3Vyc2l2ZWx5ICgkbm9kZSk7Cn0KCnN1YiByZW1vdmVfcmVjdXJzaXZlbHkgewogICAgbXkgKCRu
b2RlKSA9IEBfOwogICAgaWYgKCEoLWwgJG5vZGUpICYmICgtZCAkbm9kZSkpIHsKCWlmICghb3Bl
bmRpciAoRElSLCAkbm9kZSkpIHsKCSAgICBwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIG9wZW4g
ZGlyZWN0b3J5ICckbm9kZSc6ICQhXG4iOwoJICAgICRkaXJ0eSA9IDE7CgkgICAgZXhpdCAoMSkg
aWYgJGh5c3RlcmljYWw7CgkgICAgcmV0dXJuOwoJfQoJbXkgQHN1Ym5vZGVzID0gcmVhZGRpciAo
RElSKTsKCWZvcmVhY2ggbXkgJHN1Ym5vZGUgKEBzdWJub2RlcykgewoJICAgIG5leHQgaWYgKCgk
c3Vibm9kZSBlcSAnLicpIG9yICgkc3Vibm9kZSBlcSAnLi4nKSk7CgkgICAgcmVtb3ZlX3JlY3Vy
c2l2ZWx5ICgkbm9kZS4nLycuJHN1Ym5vZGUpOwoJfQoJY2xvc2UgKERJUik7CglpZiAoIXJtZGly
ICgkbm9kZSkpIHsKCSAgICBwcmludCBTVERFUlIgIkU6RmFpbGVkIHRvIHJlbW92ZSAnJG5vZGUn
OiAkIVxuIjsKCSAgICAkZGlydHkgPSAxOwoJICAgIGV4aXQgKDEpIGlmICRoeXN0ZXJpY2FsOwoJ
fQogICAgfSBlbHNpZiAoIXVubGluayAoJG5vZGUpKSB7CglwcmludCBTVERFUlIgIkU6RmFpbGVk
IHRvIHJlbW92ZSAnJG5vZGUnOiAkIVxuIjsKCSRkaXJ0eSA9IDE7CglleGl0ICgxKSBpZiAkaHlz
dGVyaWNhbDsKICAgIH0KfQppZiAoJGRpcnR5KSB7CiAgICBleGl0IDE7Cn0KCmV4aXQgMDsK
")
  "Remove Perl script")

(defvar ww-buffer-name "*WEREWOLF*"
  "Name of Werewolf buffer")

(defvar ww-file-processing-buffer-name "*WEREWOLF-FILE-PROCESSING*"
  "Name of Werewolf file processing buffer")

(defvar ww-buffer-terminal-name "*WEREWOLF-TERMINAL*"
  "Name of Werewolf terminal buffer")

(defvar ww-buffer-terminal-name-custom-prefix "*WEREWOLF-TERMINAL '"
  "Name of Werewolf terminal buffer custom command prefix")

(defvar ww-buffer-terminal-name-custom-suffix "'*"
  "Name of Werewolf terminal buffer custom command suffix")

(defvar ww-copy-buffer-name "*WEREWOLF-COPY-%d*"
  "Name of Werewolf Copy buffer")

(defvar ww-rename-buffer-name "*WEREWOLF-RENAME-%d*"
  "Name of Werewolf Rename buffer")

(defgroup ww-faces nil
  "Werewolf faces."
  :group 'ww-faces)

(defface ww-face-dialog-base
  '((((type tty pc) (class color))
     (:foreground "black" :background "blue")))
  "Face for highlighting dialog base stuff."
  :group 'ww-faces)
(defvar ww-face-dialog-base 'ww-face-dialog-base)

(defface ww-face-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "red" :background "blue" :weight bold)))
  "Face for highlighting dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-dialog-highlight 'ww-face-dialog-highlight)

(defface ww-face-mark-dialog-base
  '((((type tty pc) (class color))
     (:foreground "black" :background "white")))
  "Face for highlighting mark/unmark dialog base stuff."
  :group 'ww-faces)
(defvar ww-face-mark-dialog-base 'ww-face-mark-dialog-base)

(defface ww-face-mark-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "black" :background "white" :weight bold)))
  "Face for highlighting mark dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-mark-dialog-highlight 'ww-face-mark-dialog-highlight)

(defface ww-face-rename-dialog-base
  '((((type tty pc) (class color))
     (:foreground "black" :background "yellow")))
  "Face for highlighting rename dialog base stuff."
  :group 'ww-faces)
(defvar ww-face-rename-dialog-base 'ww-face-rename-dialog-base)

(defface ww-face-rename-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "red" :background "yellow" :weight bold)))
  "Face for highlighting rename dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-rename-dialog-highlight 'ww-face-rename-dialog-highlight)

(defface ww-face-mkdir-dialog-base
  '((((type tty pc) (class color))
     (:foreground "black" :background "green")))
  "Face for highlighting rename dialog base stuff."
  :group 'ww-faces)
(defvar ww-face-mkdir-dialog-base 'ww-face-mkdir-dialog-base)

(defface ww-face-mkdir-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "red" :background "green" :weight bold)))
  "Face for highlighting rename dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-mkdir-dialog-highlight 'ww-face-mkdir-dialog-highlight)

(defface ww-face-alert-dialog-base
  '((((type tty pc) (class color))
     (:foreground "black" :background "red")))
  "Face for highlighting dialog base stuff."
  :group 'ww-faces)
(defvar ww-face-alert-dialog-base 'ww-face-alert-dialog-base)

(defface ww-face-alert-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "yellow" :background "red" :weight bold)))
  "Face for highlighting alert dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-alert-dialog-highlight 'ww-face-alert-dialog-highlight)

(defface ww-face-command-line-edit
  '((((type tty pc) (class color))
     ()))
  "Face for highlighting command line edit stuff."
  :group 'ww-faces)
(defvar ww-face-command-line-edit 'ww-face-command-line-edit)

(defface ww-face-dialog-line-edit
  '((((type tty pc) (class color))
     (:foreground "black" :background "cyan")))
  "Face for highlighting dialog line edit stuff."
  :group 'ww-faces)
(defvar ww-face-dialog-line-edit 'ww-face-dialog-line-edit)

(defface ww-face-alert-dialog-highlight
  '((((type tty pc) (class color))
     (:foreground "blue" :background "red")))
  "Face for highlighting alert dialog highlighted stuff."
  :group 'ww-faces)
(defvar ww-face-alert-dialog-highlight 'ww-face-alert-dialog-highlight)

(defface ww-face-command-line-edit
  '((((type tty pc) (class color))
     ()))
  "Face for highlighting command line edit stuff."
  :group 'ww-faces)
(defvar ww-face-command-line-edit 'ww-face-command-line-edit)

(defface ww-face-search-string
  '((((type tty pc) (class color))
     (:foreground "black" :background "cyan")))
  "Face for highlighting search string."
  :group 'ww-faces)
(defvar ww-face-search-string 'ww-face-search-string)

(defface ww-face-active-selected-file
  '((((type tty pc) (class color))
     (:foreground "black" :background "cyan")))
  "Face for highlighting active selected file on active panel."
  :group 'ww-faces)
(defvar ww-face-active-selected-file 'ww-face-active-selected-file)

(defface ww-face-marked-active-selected-file
  '((((type tty pc) (class color))
     (:foreground "yellow" :background "cyan")))
  "Face for highlighting marked selected file on active panel."
  :group 'ww-faces)
(defvar ww-face-marked-active-selected-file 'ww-face-marked-active-selected-file)

(defface ww-face-inactive-selected-file
  '((((type tty pc) (class color))
     (:foreground "cyan" :weight bold)))
  "Face for highlighting selected file on inactive panel."
  :group 'ww-faces)
(defvar ww-face-inactive-selected-file 'ww-face-inactive-selected-file)

(defface ww-face-marked-inactive-selected-file
  '((((type tty pc) (class color))
     (:foreground "yellow")))
  "Face for highlighting marked selected file on inactive panel."
  :group 'ww-faces)
(defvar ww-face-marked-inactive-selected-file 'ww-face-marked-inactive-selected-file)

(defface ww-face-marked
  '((((type tty pc) (class color))
     (:foreground "yellow" :weight bold)))
  "Face for highlighting marked file."
  :group 'ww-faces)
(defvar ww-face-marked 'ww-face-marked)

(defface ww-face-directory
  '((((type tty pc) (class color))
     (:foreground "white" :weight bold)))
  "Face for highlighting directory."
  :group 'ww-faces)
(defvar ww-face-directory 'ww-face-directory)

(defface ww-face-unresolved-symlink
  '((((type tty pc) (class color))
     (:foreground "red" :weight bold)))
  "Face for highlighting unresolved symlink."
  :group 'ww-faces)
(defvar ww-face-unresolved-symlink 'ww-face-unresolved-symlink)

(defface ww-face-executable
  '((((type tty pc) (class color))
     (:foreground "green" :weight bold)))
  "Face for highlighting executable file."
  :group 'ww-faces)
(defvar ww-face-executable 'ww-face-executable)

(defface ww-face-device
  '((((type tty pc) (class color))
     (:foreground "magenta" :weight bold)))
  "Face for highlighting device file."
  :group 'ww-faces)
(defvar ww-face-device 'ww-face-device)

(defface ww-face-ipc-device
  '((((type tty pc) (class color))
     (:foreground "blue" :weight bold)))
  "Face for highlighting IPC device file."
  :group 'ww-faces)
(defvar ww-face-ipc-device 'ww-face-ipc-device)

(defface ww-face-status-perm
  '((((type tty pc) (class color))
     (:foreground "magenta")))
  "Face for highlighting permissions on statusbar."
  :group 'ww-faces)
(defvar ww-face-status-perm 'ww-face-status-perm)

(defface ww-face-status-owner
  '((((type tty pc) (class color))
     (:foreground "green")))
  "Face for highlighting user and group on statusbar."
  :group 'ww-faces)
(defvar ww-face-status-owner 'ww-face-status-owner)

(defface ww-face-status-time
  '((((type tty pc) (class color))
     (:foreground "blue")))
  "Face for highlighting time on statusbar."
  :group 'ww-faces)
(defvar ww-face-status-time 'ww-face-status-time)

(defface ww-face-status-size
  '((((type tty pc) (class color))
     (:foreground "cyan")))
  "Face for highlighting file size statusbar."
  :group 'ww-faces)
(defvar ww-face-status-size 'ww-face-status-size)


(defvar ww-search-string nil
  "String to search files")
(defvar ww-current-dir-full t
  "Full path of working directory or not")
(defvar ww-current-dir-abbreviated t
  "If TRUE then home dir is substituted with \"~\" in working directory")
(defvar ww-command-line (vector 0 0 0 '(face ww-face-command-line-edit) "" 0 0 (make-list 0 nil) 0)
  "Command line")

(defvar ww-mode-map (make-sparse-keymap)
  "Keymap for Werewolf")

(defvar ww-copy-mode-map (make-sparse-keymap)
  "Keymap for Werewolf copy buffer")

(defvar ww-rename-mode-map (make-sparse-keymap)
  "Keymap for Werewolf rename buffer")

(defvar ww-window-metrics nil
  "Window metrics")
(defvar ww-status-bar-metrics nil
  "Status bar metrics")
(defvar ww-panel-metrics (make-vector 2 nil)
  "VECTOR of 2 panel metrices")
  
(defvar ww-current-panel 0
  "Current panel: 0 - left, 1 - right")
(defvar ww-current-dialog nil
  "Current dialog: 0 - rename, 1 - remove, 2 - copy, 3 - make directory, 4 - mark/unmark, 5 - make symlink, 6 - custom commmand")
(defvar ww-current-dialog-data nil
  "Current dialog data (depends on current dialog)")

(defvar ww-panel-data (make-vector 2 nil)
  "List of 2 (left and right) panel data structures: 0 - pattern, 1 - workdir, 2 - inodes, \
3 - offset, 4 - selected")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-interactive (helper) functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ww-get-selected-file (panel)
  "Get selected filename of given panel"

  (let* ((inodes (aref panel 2))
	 (selected (aref panel 4))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (dir-count (length dirs)))
    (if (< selected dir-count) (nth selected dirs) (nth (- selected dir-count) files)))
  )

(defun ww-escape-filename (filename)
  "Escape filename"
  (replace-regexp-in-string
   "\\(\s\\|\\\\\\|\|\\|\\[\\|\\]\\|\\\"\\|[`;'!$&*(){}<>?]\\)"
   "\\\\\\1" filename t)
  )

(defun ww-match-names-in-list (name-list wildcard-pattern)
  "Match given name list by given wildcard"

  (let ((regexp-pattern (wildcard-to-regexp wildcard-pattern))
  	matched-list)
    (save-match-data
      (while name-list
  	(cond ((and (string-match regexp-pattern (car name-list))
		    (= (match-beginning 0) 0)
		    (= (match-end 0) (length (car name-list))))
  	       (setq matched-list (cons (car name-list) matched-list))))
  	(setq name-list (cdr name-list))))
    matched-list)
  )

(defun ww-get-buffer-switch-mode (command-keys)
  "Get buffer switch mode depending on command keys"
  (cond ((equal command-keys "\033j") 1)
	((string-equal command-keys "\C-j") 2)
	((string-equal command-keys "\033\C-j") 3)
	(t 0))
  )

(defun ww-term-handle-exit (process-name msg)
  "Write process exit (or other change) message MSG in the current buffer."
  (let ((buffer-read-only nil)
	(omax (point-max))
	(opoint (point)))
    ;; Record where we put the message, so we can ignore it
    ;; later on.
    (goto-char omax)
    (insert "\n=== Process " process-name " " msg)
    ;; Force mode line redisplay soon.
    (force-mode-line-update)
    (when (and opoint (< opoint omax))
      (goto-char opoint))))

(defun ww-term-man-handle-exit (process-name msg)
  "Write process exit (or other change) message MSG in the current buffer."
  (let ((buffer-read-only nil)
	(omax (point-max))
	(opoint (point)))
    ;; Record where we put the message, so we can ignore it
    ;; later on.
    (goto-char omax)
    ;; (insert "\n=== Process " process-name " " msg)
    (goto-char (point-min))
    ;; Force mode line redisplay soon.
    (force-mode-line-update)
    (when (and opoint (< opoint omax))
      (goto-char opoint))))


(defun ww-term-exec-1 (name buffer command switches)
  ;; We need to do an extra (fork-less) exec to run stty.
  ;; (This would not be needed if we had suitable Emacs primitives.)
  ;; The 'if ...; then shift; fi' hack is because Bourne shell
  ;; loses one arg when called with -c, and newer shells (bash,  ksh) don't.
  ;; Thus we add an extra dummy argument "..", and then remove it.
  (let ((process-environment
	 (nconc
	  (list
	   "TERM=eterm"
	   (format "INSIDE_EMACS=%s,term:%s" emacs-version term-protocol-version)
	   (format "LINES=%d" term-height)
	   (format "COLUMNS=%d" term-width))
	  process-environment))
	(process-connection-type t)
	;; We should suppress conversion of end-of-line format.
	(inhibit-eol-conversion t)
	;; The process's output contains not just chars but also binary
	;; escape codes, so we need to see the raw output.  We will have to
	;; do the decoding by hand on the parts that are made of chars.
	(coding-system-for-read 'binary))
    (apply 'start-process name buffer
	   "/bin/bash" "-c" (format "stty -nl echo rows %d columns %d sane 2>/dev/null; if [ $1 = .. ]; then shift; fi; exec \"$@\""
				    term-height term-width) ".." command switches)))

(defun ww-term-exec (buffer name command switches &optional sentinel)
  "Start up a process in buffer for term modes.
Blasts any old process running in the buffer.  Doesn't set the buffer mode.
You can use this to cheaply run a series of processes in the same term
buffer.  The hook `term-exec-hook' is run after each exec."
  (save-excursion
    (set-buffer buffer)
    (let ((proc (get-buffer-process buffer)))	; Blast any old process.
      (when proc (delete-process proc)))
    ;; Crank up a new process
    (let ((proc (ww-term-exec-1 name buffer command switches)))
      (make-local-variable 'term-ptyp)
      (setq term-ptyp process-connection-type) ; t if pty, nil if pipe.
      ;; Jump to the end, and set the process mark.
      (goto-char (point-max))
      (set-marker (process-mark proc) (point))
      (set-process-filter proc 'term-emulate-terminal)
      (set-process-sentinel proc (or sentinel 'term-sentinel))
    (run-hooks 'term-exec-hook)
    buffer)))

(defun ww-execute-command (cmdline buffer-switch-mode &optional cmdargs)
  "Execute command (BUFFER-SWITCH-MODE: (0: background, 1: foreground, 2: foreground, switch back, 3: foreground, new separate buffer, 4: foreground, new separate buffer, goto BOF))"
  (let* ((command (if cmdargs cmdline "/bin/bash"))
	 (args (if cmdargs cmdargs (list "-c" cmdline)))
	 (current-buffer (current-buffer))
	 (wd (aref (aref ww-panel-data ww-current-panel) 1))
	 (buffer (if (or (= buffer-switch-mode 3) (= buffer-switch-mode 4))
		     (generate-new-buffer (concat ww-buffer-terminal-name-custom-prefix cmdline ww-buffer-terminal-name-custom-suffix))
		   (get-buffer-create ww-buffer-terminal-name))))
    (save-excursion
      (set-buffer buffer)
      ;; If no process, or nuked process, crank up a new one and put buffer in
      ;; term mode.  Otherwise, leave buffer and existing process alone.
      (cond ((not (term-check-proc buffer))
	     (term-mode) ;; Install local vars, mode, keymap, ...
	     (setq default-directory (concat wd "/"))
	     (ww-term-exec buffer (concat "'" cmdline "'") command args
			   (cond ((= buffer-switch-mode 0) 'ww-with-message-term-sentinel)
				 ((= buffer-switch-mode 1) 'ww-with-message-term-sentinel)
				 ((= buffer-switch-mode 2) 'ww-returning-with-message-term-sentinel)
				 ((= buffer-switch-mode 3) 'ww-with-message-term-sentinel)
				 ((= buffer-switch-mode 4) 'ww-with-message-term-sentinel)))))
      (term-mode)
      (term-char-mode)
      (goto-char (point-max)))
    (if (not (= buffer-switch-mode 0)) (switch-to-buffer buffer))
    (if (= buffer-switch-mode 4) (goto-char (point-min))))
  )

(defun ww-enter-dir (dir &optional current-filename)
  "Enter directory"
  
  (cond ((not (access-file dir "Failed to read directory"))
	 (aset (aref ww-panel-data ww-current-panel) 1 dir)
	 (aset (aref ww-panel-data ww-current-panel) 3 0)
	 (aset (aref ww-panel-data ww-current-panel) 4
	       (if current-filename
		   (progn
		     (ww-panel-reread ww-current-panel)
		     (let* ((current-file 0)
			    (panel-data (aref ww-panel-data ww-current-panel))
			    (wd (aref panel-data 1))
			    (dirs (car (aref panel-data 2)))
			    (i 0))
		       (while dirs
			 (cond ((string-equal (ww-expand-filename (caar dirs) wd) current-filename)
				(setq current-file i)
				(setq dirs nil))
			       (t
				(setq i (1+ i))
				(setq dirs (cdr dirs)))))
		       current-file))
		 0))
	 (setq default-directory (concat dir "/"))))
  )

(defun ww-enter-file (file)
  "Enter file"
  (let ((buffer-switch-mode (ww-get-buffer-switch-mode (this-command-keys))))
    (cond ((string-match "\\.\\(mpe?g\\|mp4\\|divx\\|avi\\|ogv\\|mov\\|\m4v\\|\
wmv\\|asf\\|mp[eg]\\|vob\\|ra?m\\|flv\\|mkv\\|ts\\|m2ts\\|webm\\)\\(\\.part\\)?$" file)
	   (ww-execute-command "mplayer" buffer-switch-mode (list file)))
	  ((string-match "\\.\\(png\\|svg\\|jpe?g\\|tiff?\\|bmp\\|tga\\|gif\\)$" file)
	   (ww-execute-command "gqview" buffer-switch-mode (list file)))
	  ((string-match "\\.\\(exr\\)$" file)
	   (ww-execute-command "exrdisplay" buffer-switch-mode (list file)))
	  ((string-match "\\.\\(ogg\\|flac\\|wav\\|mp3\\)$" file)
	   (ww-execute-command "mplayer" buffer-switch-mode (list file)))
	  ((string-match "\\.\\(ape\\|m4a\\)$" file)
	   (ww-execute-command "mplayer" buffer-switch-mode (list "-vc" "frameno" file)))
	  ((string-match "\\.\\(umx\\)$" file)
	   (ww-execute-command "xmp" buffer-switch-mode (list file)))
	  ((string-match "\\.\\(nomrhis\\)$" file)
	   (ww-execute-command "kernelpanic" buffer-switch-mode (list "-c" file)))
	  ((string-match "\\.\\(pcd\\|vtk\\)$" file)
	   (ww-execute-command "pcl_viewer" buffer-switch-mode (list file)))
	  ((string-match "/Flash[^/]+$" file)
	   (ww-execute-command "mplayer" buffer-switch-mode (list file)))
	  ((file-executable-p file)
	   (ww-execute-command (concat "\"" (replace-regexp-in-string "\"" "\\\\\"" file) "\"") buffer-switch-mode))
	  (t
	   (bury-buffer (current-buffer))
	   (find-file file))))
  )

(defun ww-enter-file-no-exec (file read-only)
  "Enter file (never execute)"
  (bury-buffer (current-buffer))
  (if read-only (find-file-read-only file) (find-file file))
  )

(defun ww-expand-filename (name dir)
  "Expand filename more accurate"
  (let ((expanded (expand-file-name name dir)))
    (if (string-equal expanded "/..") "/" expanded))
  )

(defun ww-current-dir-name (name)
  "Unexpand and/or abbreviate current filename"
  (let ((abbr (if ww-current-dir-abbreviated
		  (abbreviate-file-name name) name)))
    (if ww-current-dir-full abbr
      (if (string-equal abbr "/") "/"
	(substring abbr (string-match "[^/]*$" abbr)))))
  )

(defun ww-limit-string (name len)
  "Limit filename to length"
  (let* ((full-len (length name))
	 (left (/ len 2))
	 (right (- full-len (/ (- len 1) 2))))
    (if (< len full-len)
	(concat (substring name 0 left) "~" (substring name right)) name))
  )

(defun ww-check-symlink (name panel)
  "Check if symlink points to existing file"
  (file-exists-p (ww-expand-filename
		  (file-symlink-p name)
		  (aref (aref ww-panel-data panel) 1)))
  )

(defun ww-put-cursor (row col)
  "Just putting cursor"
  (goto-line (1+ row))
  (move-to-column col t)
  )

(defun ww-clear-string (row col width &optional prop)
  "Replacing insert"
  (goto-line (1+ row))
  (move-to-column col t)
  (delete-char (min width (- (point-at-eol) (point))))
  (insert-char ?\s width)
  (if prop (ww-adjust-text prop row col width))
  )

(defun ww-put-string (row col str &optional prop)
  "Replacing insert"
  (let* ((width (length str)))
    (goto-line (1+ row))
    (move-to-column col t)
    (delete-char (min width (- (point-at-eol) (point))))
    (insert str)
    (if prop (ww-adjust-text prop row col width)))
  )

(defun ww-put-char (row col char &optional prop)
  "Replacing insert"
  (goto-line (1+ row))
  (move-to-column col t)
  (if (not (eolp)) (delete-char 1))
  (insert char)
  (if prop (ww-adjust-text prop row col 1))
  )

(defun ww-init-buffer ()
  "Init WW buffer"

  (let ((current-buffer (get-buffer ww-buffer-name)))
    (cond (current-buffer	      ;; If buffer already exists
	   (set-buffer current-buffer)) ;; then we should only switch to that buffer
	  (t ;; else we honestly initialize buffer and rest
	   (set-buffer (get-buffer-create ww-buffer-name))
	   (set-buffer-multibyte t)
	   (setq redisplay-dont-pause nil)
	   (loop for i from 0 to 1 do
		 (aset ww-panel-data i (make-vector 5 nil))
		 (aset (aref ww-panel-data i) 0 nil)
		 (aset (aref ww-panel-data i) 1 (expand-file-name ""))
		 (aset (aref ww-panel-data i) 2 nil)
		 (aset (aref ww-panel-data i) 3 0)
		 (aset (aref ww-panel-data i) 4 0))
	   (setq tab-width 1)
	   (setq truncate-lines t))))
  )

(defun ww-init-file-processing-buffer ()
  "Init WW file processing buffer"

  (let ((current-buffer (get-buffer ww-file-processing-buffer-name)))
    ;; If buffer buffer already exists then we should only switch to that buffer
    (if current-buffer
	(set-buffer current-buffer)
      (progn
	(setq current-buffer (get-buffer-create ww-file-processing-buffer-name))
	(set-buffer current-buffer)
	(setq tab-width 1)
	(setq truncate-lines t)))
    current-buffer)
  )

(defun ww-update-metrics ()
  "Update metrics"

  (let ((prev-cl-w (aref ww-command-line 2))
	(win-w (max (window-width) 60))
	(win-h (max (window-height) 16)))
    (setq ww-window-metrics (vector win-h win-w))
    (aset ww-panel-metrics 0 (vector 1 0 (- win-h 6) (/ (1- win-w) 2)))
    (aset ww-panel-metrics 1 (vector 1 (/ (1+ win-w) 2) (- win-h 6) (1- (/ win-w 2))))
    (setq ww-status-bar-metrics (vector (- win-h 4) 0 (1- win-w)))
    (aset ww-command-line 0 (- win-h 2))
    (aset ww-command-line 1 0)
    (aset ww-command-line 2 (- win-w 2))
    (unless (= prev-cl-w (- win-w 2))
      (progn (aset ww-command-line 5 0)
	     (aset ww-command-line 6 0))))
  )

(defun ww-panel-reread (panel)
  "Reread files in panel"

  (aset (aref ww-panel-data panel) 2
	(ww-file-lists (aref (aref ww-panel-data panel) 1) panel (aref (aref ww-panel-data panel) 0)))
  )

(defun ww-panel-update-selection (panel)
  "Update selection"

  (let* ((height (aref (aref ww-panel-metrics 0) 2))
	 (panel-data (aref ww-panel-data panel))
	 (selected (aref panel-data 4))
	 (offset (aref panel-data 3))
	 (count (caddr (aref panel-data 2))))
    (if (< selected offset)
	(progn
	  (while (< selected offset)
	    (setq offset (- offset (/ height 2))))
	  (if (< offset 0) (setq offset 0))
	  (aset (aref ww-panel-data panel) 3 offset)
	  t)
      (if (>= selected (+ offset height))
	  (progn
	    (while (>= selected (+ offset height))
	      (setq offset (+ offset (/ height 2))))
  	    (if (> offset (- count height))
  		(setq offset (- count height)))
	    (if (< offset 0)
		(setq offset 0))
	    (aset (aref ww-panel-data panel) 3 offset)
	    t)
	nil)))
  )

(defun ww-file-lists (directory panel &optional pattern)
  "Create file lists for DIRECTORY.
The car is the list of directories, the cdr is list of files.
If PATTERN is set, return only directories and files matching PATTERN"
  
  (setq directory (ww-expand-filename directory (aref (aref ww-panel-data panel) 1)))
  (let ((default-directory (concat directory "/"))
        (dir (directory-files directory nil pattern))
        (dirs)
        (files)
	(count 0)
	(name)
	(attribs))
    (while dir
      (setq name (car dir))
      (cond ((not (string-match "^\\.\\{1,2\\}$" name))
	     (setq count (1+ count))
	     (setq attribs (file-attributes name))
	     (if (file-directory-p name)
		 (setq dirs (cons (cons name (cons nil attribs)) dirs))
	       (setq files (cons (cons name (cons nil attribs)) files)))))
      (setq dir (cdr dir)))
    (let ((nl (cons (nreverse dirs) (list (nreverse files) count))))nl))
  )

(defun ww-adjust-text (prop top left width)
  "Setting parameters on text line"

  (let ((lpoint) (rpoint))
    (goto-line (1+ top))
    (move-to-column left t)
    (setq lpoint (point))
    (move-to-column (+ left width) t)
    (setq rpoint (point))
    (add-text-properties lpoint rpoint prop))
  )

(defun ww-switch-to-file (prev-fileno fileno)
  "Goto file 'fileno'"

  (let ((panel-data (aref ww-panel-data ww-current-panel)))
    (aset panel-data 4 fileno))
  (ww-redraw ww-current-panel (list prev-fileno fileno))
  )

(defun ww-draw-panel (panel)
  "Drawing panel"
  (setq buffer-read-only nil)

  (let* ((metrics (aref ww-panel-metrics panel))
	 (top (aref metrics 0))
	 (left (aref metrics 1))
	 (height (aref metrics 2))
	 (width (aref metrics 3))
	 (panel-data (aref ww-panel-data panel))
	 (offset (aref panel-data 3))
	 (i (- 0 offset))
	 (local-selected (- (aref panel-data 4) offset))
	 (inodes (aref panel-data 2))
	 (wd (aref panel-data 1))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (current nil)
	 (current-full nil)
	 (current-dir (ww-limit-string (ww-current-dir-name wd) (- width 6)))
	 (text-prop)
	 (marked-sel-prop (if (= panel ww-current-panel) '(face ww-face-marked-active-selected-file)
			    '(face ww-face-marked-inactive-selected-file)))
	 (sel-prop (if (= panel ww-current-panel) '(face ww-face-active-selected-file)
		     '(face ww-face-inactive-selected-file)))
	 (type)
	 (perm)
	 (marked)
	 (voff top))
    (ww-put-string (1- top) left (concat "--> [" current-dir "]"))
    (ww-adjust-text '(face ww-face-directory) (1- top) (+ left 5) (length current-dir))
    (while (and dirs (< i height))
      (cond ((>= i 0)
	     (setq current (caar dirs))
	     (setq marked (nth 1 (car dirs)))
	     (setq current-full (ww-expand-filename current wd))
	     (setq type (string-to-char (nth 10 (car dirs))))
	     (setq current (ww-limit-string current (1- width)))
	     (ww-put-string voff (1+ left) current)
	     (cond ((char-equal type ?l) (ww-put-char voff left ?~))
		   (t (ww-put-char voff left ?/)))
	     (if marked (ww-adjust-text '(face ww-face-marked) voff left width)
		 (ww-adjust-text '(face ww-face-directory) voff left width))
	     (cond ((= local-selected i)
		    (ww-adjust-text (if marked marked-sel-prop sel-prop) voff left width)))
	     (setq voff (1+ voff))))
      (setq i (1+ i))
      (setq dirs (cdr dirs)))
    (while (and files (< i height))
      (if (>= i 0)
	  (progn
	    (setq current (caar files))
	    (setq marked (nth 1 (car files)))
	    (setq current-full (ww-expand-filename current wd))
	    (setq perm (nth 10 (car files)))
	    (if (not perm) (setq perm "----------"))
	    (setq type (string-to-char perm))
	    (setq current (ww-limit-string current (1- width)))
	    (ww-put-string voff (1+ left) current)
	    (setq text-prop nil)
	    (cond ((char-equal type ?l)
		   (cond ((ww-check-symlink current-full panel)
			  (ww-put-char voff left ?@))
			 (t
			  (ww-put-char voff left ?!)
			  (setq text-prop '(face ww-face-unresolved-symlink)))))
		  ((char-equal type ?c)
		   (ww-put-char voff left ?-)
		   (setq text-prop '(face ww-face-device)))
		  ((char-equal type ?b)
		   (ww-put-char voff left ?+)
		   (setq text-prop '(face ww-face-device)))
		  ((char-equal type ?p)
		   (ww-put-char voff left ?|)
		   (setq text-prop '(face ww-face-ipc-device)))
		  ((char-equal type ?s)
		   (ww-put-char voff left ?=)
		   (setq text-prop '(face ww-face-ipc-device)))
		  ((string-match "[xt]" perm)
		   (ww-put-char voff left ?*)
		   (setq text-prop '(face ww-face-executable))))
	    (if marked (setq text-prop '(face ww-face-marked)))
	    (if text-prop (ww-adjust-text text-prop voff left width))
	    (cond ((= local-selected i)
		   (ww-adjust-text (if marked marked-sel-prop sel-prop) voff left width)))
	    (setq voff (1+ voff))))
      (setq i (1+ i))
      (setq files (cdr files))))
  (setq buffer-read-only t)
  )

(defun ww-draw-panel-file-pair (panel file-list)
  "Drawing panel"

  (setq buffer-read-only nil)
  (let* ((metrics (aref ww-panel-metrics panel))
	 (top (aref metrics 0))
	 (left (aref metrics 1))
	 (height (aref metrics 2))
	 (width (aref metrics 3))
	 (panel-data (aref ww-panel-data panel))
	 (offset (aref panel-data 3))
	 (i (- 0 offset))
	 (first (- (car file-list) offset))
	 (second (- (cadr file-list) offset))
	 (local-selected (- (aref panel-data 4) offset))
	 (inodes (aref panel-data 2))
	 (wd (aref panel-data 1))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (current nil)
	 (current-full nil)
	 (current-dir (ww-limit-string (ww-current-dir-name wd) (- width 6)))
	 (text-prop)
	 (marked-sel-prop (if (= panel ww-current-panel) '(face ww-face-marked-active-selected-file)
			    '(face ww-face-marked-inactive-selected-file)))
	 (sel-prop (if (= panel ww-current-panel)
		       '(face ww-face-active-selected-file)
		     '(face ww-face-inactive-selected-file)))
	 (type)
	 (voff top))
    (while (and dirs (< i height))
      (if (>= i 0)
	  (progn
	    (if (or (= i first) (= i second))
		(progn
		  (setq current (caar dirs))
		  (setq marked (nth 1 (car dirs)))
		  (setq current-full (ww-expand-filename current wd))
		  (setq type (string-to-char (nth 10 (car dirs))))
		  (setq current (ww-limit-string current (1- width)))
		  (ww-clear-string voff left width)
		  (ww-put-string voff (1+ left) current)
		  (cond ((char-equal type ?l) (ww-put-char voff left ?~))
			(t (ww-put-char voff left ?/)))
		  (if marked (ww-adjust-text '(face ww-face-marked) voff left width)
		    (ww-adjust-text '(face ww-face-directory) voff left width))
		  (cond ((= local-selected i)
			 (ww-adjust-text (if marked marked-sel-prop sel-prop) voff left width)))))
	    (setq voff (1+ voff))))
      (setq i (1+ i))
      (setq dirs (cdr dirs)))
    (while (and files (< i height))
      (if (>= i 0)
	  (progn
	    (if (or (= i first) (= i second))
		(let ((perm))
		  (setq current (caar files))
		  (setq marked (nth 1 (car files)))
		  (setq current-full (ww-expand-filename current wd))
		  (setq perm (nth 10 (car files)))
		  (if (not perm) (setq perm "----------"))
		  (setq type (string-to-char perm))
		  (setq current (ww-limit-string current (1- width)))
		  (ww-clear-string voff left width)
		  (ww-put-string voff (1+ left) current)
		  (setq text-prop nil)
		  (cond ((char-equal type ?l)
			 (cond ((ww-check-symlink current-full panel)
				(ww-put-char voff left ?@))
			       (t
				(ww-put-char voff left ?!)
				(setq text-prop '(face ww-face-unresolved-symlink)))))
			((char-equal type ?c)
			 (ww-put-char voff left ?-)
			 (setq text-prop '(face ww-face-device)))
			((char-equal type ?b)
			 (ww-put-char voff left ?+)
			 (setq text-prop '(face ww-face-device)))
			((char-equal type ?p)
			 (ww-put-char voff left ?|)
			 (setq text-prop '(face ww-face-ipc-device)))
			((char-equal type ?s)
			 (ww-put-char voff left ?=)
			 (setq text-prop '(face ww-face-ipc-device)))
			((string-match "[xt]" perm)
			 (ww-put-char voff left ?*)
			 (setq text-prop '(face ww-face-executable))))
		  (if marked (setq text-prop '(face ww-face-marked)))
		  (if text-prop (ww-adjust-text text-prop voff left width))
		  (cond ((= local-selected i)
			 (ww-adjust-text (if marked marked-sel-prop sel-prop) voff left width)))))
	    (setq voff (1+ voff))))
      (setq i (1+ i))
      (setq files (cdr files)))
    )
  (setq buffer-read-only t)
  )


(defun ww-draw-status-bar (&optional clear)
  "Drawing statusbar"

  (setq buffer-read-only nil)
  (let* ((top (aref ww-status-bar-metrics 0))
	 (left (aref ww-status-bar-metrics 1))
	 (width (aref ww-status-bar-metrics 2))
	 (i 0)
	 (panel-data (aref ww-panel-data ww-current-panel))
	 (inodes (aref panel-data 2))
	 (selected (aref panel-data 4))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (count (caddr inodes))
	 (continue t)
	 (current))
    (if clear (ww-clear-string top left width))
    (cond (ww-search-string
	   (let* ((left2 (1+ left))
		  (width2 (- width 2))
		  (search-string (ww-limit-string ww-search-string width2)))
	     (ww-put-string top left2 search-string)
	     (ww-adjust-text '(face ww-face-search-string) top left width)
	     (ww-put-cursor top (+ left2 (length search-string)))))
	  (t
	   (setq current (ww-get-selected-file panel-data))
	   (if current
	       (let* ((name (car current))
		      (perm (nth 10 current))
		      (user (nth 4 current))
		      (group (nth 5 current))
		      (size (nth 9 current))
		      (mtime (nth 7 current)))
		 (cond (perm
			(setq user (or (user-login-name user)
				       (number-to-string user)))
			(setq group (number-to-string group))
			(setq size (format "% 11.0f" size))
			(setq mtime (format-time-string "%b %e %y %k:%M:%S" (nth 7 current)))
			(ww-put-string top (- (+ left width) 62 ) perm '(face ww-face-status-perm))
			(ww-put-string top (- (+ left width) 50 ) user '(face ww-face-status-owner))
			(ww-put-string top (- (+ left width) 40 ) group '(face ww-face-status-owner))
			(ww-put-string top (- (+ left width) 30 ) mtime '(face ww-face-status-time))
			(ww-put-string top (- (+ left width) 11) size '(face ww-face-status-size))
			(ww-put-string top left (ww-limit-string (concat name "  ") (- width 10))))))))))
  (setq buffer-read-only t)
  )

(defun ww-draw-rename-dialog (&optional dynamics-only)
  "Drawing rename dialog"
  
  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (input-focus (aref ww-current-dialog-data 4))
	 (targets (aref ww-current-dialog-data 7))
	 (target-count (aref ww-current-dialog-data 8))
	 (prop-base '(face ww-face-rename-dialog-base))
	 (prop-highlight '(face ww-face-rename-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -3) " Rename " prop-highlight)
	  (cond (targets
		 (ww-put-string (+ y 2) (+ x 3) (format "Source (%d inodes) mask:" target-count) prop-base))
		(t
		 (ww-put-string (+ y 2) (+ x 3) "Source:" prop-base)))
	  (ww-put-string (+ y 5) (+ x 3) "Destination:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 6 5)))
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 5 6))))
  (setq buffer-read-only t)
  )

(defun ww-draw-copy-dialog (&optional dynamics-only)
  "Drawing copy dialog"
  
  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (input-focus (aref ww-current-dialog-data 4))
	 (targets (aref ww-current-dialog-data 7))
	 (target-count (aref ww-current-dialog-data 8))
	 (prop-base '(face ww-face-dialog-base))
	 (prop-highlight '(face ww-face-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -3) " Copy " prop-highlight)
	  (cond (targets
		 (ww-put-string (+ y 2) (+ x 3) (format "Source (%d inodes) mask:" target-count) prop-base))
		(t
		 (ww-put-string (+ y 2) (+ x 3) "Source:" prop-base)))
	  (ww-put-string (+ y 5) (+ x 3) "Destination:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 6 5)))
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 5 6))))
  (setq buffer-read-only t)
  )

(defun ww-draw-make-directory-dialog (&optional dynamics-only)
  "Drawing make directory dialog"

  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (prop-base '(face ww-face-mkdir-dialog-base))
	 (prop-highlight '(face ww-face-mkdir-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -8) " Make directory " prop-highlight)
	  (ww-put-string (+ y 2) (+ x 3) "Directory:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data 4)))
  (setq buffer-read-only t)
  )

(defun ww-draw-custom-command-dialog (&optional dynamics-only)
  "Drawing custom command dialog"

  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (prop-base '(face ww-face-dialog-base))
	 (prop-highlight '(face ww-face-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -8) " Custom command " prop-highlight)
	  (ww-put-string (+ y 2) (+ x 3) "Command:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data 4)))
  (setq buffer-read-only t)
  )

(defun ww-draw-make-symlink-dialog (&optional dynamics-only)
  "Drawing make symlink dialog"

  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (input-focus (aref ww-current-dialog-data 6))
	 (prop-base '(face ww-face-dialog-base))
	 (prop-highlight '(face ww-face-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -8) " Make symlink " prop-highlight)
	  (ww-put-string (+ y 2) (+ x 3) "Source:" prop-base)
	  (ww-put-string (+ y 5) (+ x 3) "Destination:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 5 4)))
    (ww-le-draw (aref ww-current-dialog-data (if (equal input-focus 0) 4 5))))
  (setq buffer-read-only t)
  )

(defun ww-draw-mark-dialog (&optional dynamics-only)
  "Drawing mark/unmark dialog"

  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (mark (aref ww-current-dialog-data 6))
	 (prop-base '(face ww-face-mark-dialog-base))
	 (prop-highlight '(face ww-face-mark-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?╭ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?╰ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?╯ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?╮ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -4) (if mark " Mark " " Unmark ") prop-highlight)
	  (ww-put-string (+ y 2) (+ x 3) "Mask:" prop-base)))
    ;; Dynamics
    (ww-le-draw (aref ww-current-dialog-data 4)))
  (setq buffer-read-only t)
  )

(defun ww-draw-remove-dialog (&optional dynamics-only)
  "Drawing remove dialog"
  
  (setq buffer-read-only nil)
  ;; Draw statics
  (let* ((w (aref ww-current-dialog-data 0))
	 (h (aref ww-current-dialog-data 1))
	 (x (aref ww-current-dialog-data 2))
	 (y (aref ww-current-dialog-data 3))
	 (prop-base '(face ww-face-alert-dialog-base))
	 (prop-highlight '(face ww-face-alert-dialog-highlight))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (if (not dynamics-only)
	(progn
	  ;; Clear all
	  (loop for i from y to (+ y (1- h)) do
		(ww-clear-string i x w prop-base))
	  ;; Statics
	  (ww-put-char (1+ y) (1+ x) ?┌ prop-base)
	  (ww-put-char (+ y h -2) (1+ x) ?└ prop-base)
	  (ww-put-char (+ y h -2) (+ x w -2) ?┘ prop-base)
	  (ww-put-char (1+ y) (+ x w -2) ?┐ prop-base)
	  (loop for i from (+ y 2) to (+ y h -3) do
		(ww-put-char i (1+ x) ?│ prop-base)
		(ww-put-char i (+ x w -2) ?│ prop-base))
	  (loop for i from (+ x 2) to (+ x w -3) do
		(ww-put-char (1+ y) i ?─ prop-base)
		(ww-put-char (+ y h -2) i ?─ prop-base))
	  (ww-put-string (1+ y) (+ x (/ w 2) -8) " Remove inodes " prop-highlight)
	  (ww-put-string (+ y 2) (+ x 3) "Really delete?" prop-base)))
    ;; No dynamics
    )
  (setq buffer-read-only t)
  )

(defun ww-draw-current-dialog ()
  "Drawing current dialog"

  (cond ((= ww-current-dialog 0)
	 (ww-draw-rename-dialog))
	((= ww-current-dialog 1)
	 (ww-draw-remove-dialog))
	((= ww-current-dialog 2)
	 (ww-draw-copy-dialog))
	((= ww-current-dialog 3)
	 (ww-draw-make-directory-dialog))
	((= ww-current-dialog 4)
	 (ww-draw-mark-dialog))
	((= ww-current-dialog 5)
	 (ww-draw-make-symlink-dialog))
	((= ww-current-dialog 6)
	 (ww-draw-custom-command-dialog)))
  )

(defun ww-process-command-line (char)
  "Process command line"

  (setq buffer-read-only nil)
  (if (or (equal char "\10") (equal char "\177")) ;; Backspace
      (ww-le-kill-char-back ww-command-line)
    (unless (or (equal char "\0") (equal char "\31") (equal char "\33"))
      (ww-le-insert ww-command-line char)))
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-process-search (char)
  "Process search"

  (let ((len (length ww-search-string))
	(new-string))
    (if (or (equal char "\10") (equal char "\177")) ;; Backspace
	(if (> len 0) (setq new-string (substring ww-search-string 0 (1- len))))
      (setq new-string (concat ww-search-string char)))
    (let* ((len (length new-string))
	   (panel-data (aref ww-panel-data ww-current-panel))
	   (inodes (aref panel-data 2))
	   (dirs)
	   (files)
	   (count (caddr inodes))
	   (continue t)
	   (current)
	   (i)
	   (skip (aref panel-data 4))
	   (pos)
	   (still-search 2))
      (while (> still-search 0)
	(setq dirs (car inodes))
	(setq files (cadr inodes))
	(setq i 0)
	(while (and dirs continue)
	  (setq current (caar dirs))
	  (if (= skip 0)
	      (if (and (<= len (length current))
		       (string-equal (substring current 0 len) new-string))
		  (progn (setq pos i)
			 (setq continue nil)))
	    (setq skip (1- skip)))
	  (setq i (1+ i))
	  (setq dirs (cdr dirs)))
	(while (and files continue)
	  (setq current (caar files))
	  (if (= skip 0)
	      (if (and (<= len (length current))
		       (string-equal (substring current 0 len) new-string))
		  (progn (setq pos i)
			 (setq continue nil)))
	    (setq skip (1- skip)))
	  (setq i (1+ i))
	  (setq files (cdr files)))
	(if pos (progn (aset panel-data 4 pos)
		       (setq ww-search-string new-string)
		       (setq still-search 0))
	  (setq still-search (1- still-search))))))
  )

(defun ww-process-rename-dialog (char)
  "Process rename dialog"

  (let* ((input-focus (aref ww-current-dialog-data 4))
	 (focused-line-edit (aref ww-current-dialog-data (if (equal input-focus 0) 5 6))))
    (cond ((or (equal char "\t") (equal char "\C-o"))
	   (aset ww-current-dialog-data 4 (if (equal input-focus 0) 1 0)))
	  ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   (let ((source-mask (aref (aref ww-current-dialog-data 5) 4)))
	     (ww-rename (aref (aref ww-panel-data ww-current-panel) 1)
			(aref (aref ww-current-dialog-data 6) 4)
			(or (ww-match-names-in-list (aref ww-current-dialog-data 7) source-mask) (list source-mask))))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward focused-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back focused-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word focused-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word focused-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home focused-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end focused-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line focused-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char focused-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word focused-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back focused-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back focused-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert focused-line-edit char))))
  (if ww-current-dialog
      (ww-draw-rename-dialog t)
    (ww-redraw))
  )

(defun ww-process-remove-dialog (char)
  "Process remove dialog"

  (cond ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	 (ww-remove (aref ww-current-dialog-data 4) (aref ww-current-dialog-data 5))
	 (setq ww-current-dialog nil)))
  (if ww-current-dialog (ww-draw-remove-dialog t) (ww-redraw))
  )

(defun ww-process-copy-dialog (char)
  "Process copy dialog"

  (let* ((input-focus (aref ww-current-dialog-data 4))
	 (focused-line-edit (aref ww-current-dialog-data (if (equal input-focus 0) 5 6))))
    (cond ((or (equal char "\t") (equal char "\C-o"))
	   (aset ww-current-dialog-data 4 (if (equal input-focus 0) 1 0)))
	  ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   (let ((source-mask (aref (aref ww-current-dialog-data 5) 4)))
	     (ww-copy (aref (aref ww-panel-data ww-current-panel) 1)
		      (aref (aref ww-current-dialog-data 6) 4)
		      (or (ww-match-names-in-list (aref ww-current-dialog-data 7) source-mask) (list source-mask))))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward focused-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back focused-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word focused-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word focused-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home focused-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end focused-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line focused-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char focused-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word focused-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back focused-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back focused-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert focused-line-edit char))))
  (if ww-current-dialog
      (ww-draw-copy-dialog t)
    (ww-redraw))
  )

(defun ww-process-make-directory-dialog (char)
  "Process make directory dialog"

  (let* ((directory-line-edit (aref ww-current-dialog-data 4))
	 (work-dir (aref ww-current-dialog-data 5))
	 (given-dir (aref (aref ww-current-dialog-data 4) 4)))
    (cond ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   (ww-make-directory (if (equal (substring given-dir 0 1) "/")
				  given-dir (concat work-dir "/" given-dir)))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward directory-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back directory-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word directory-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word directory-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home directory-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end directory-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line directory-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char directory-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word directory-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back directory-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back directory-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\t") (equal char "\C-o")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert directory-line-edit char))))
  (if ww-current-dialog (ww-draw-make-directory-dialog t) (ww-redraw))
  )

(defun ww-process-custom-command-dialog (char)
  "Process custom command dialog"

  (let* ((command-line-edit (aref ww-current-dialog-data 4))
	 (work-dir (aref ww-current-dialog-data 5))
	 (given-dir (aref (aref ww-current-dialog-data 4) 4)))
    (cond ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   ;; (ww-make-directory (if (equal (substring given-dir 0 1) "/")
	   ;; 			  given-dir (concat work-dir "/" given-dir)))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-i")
	   (let ((escaped-filename (ww-escape-filename (car (ww-get-selected-file (aref ww-panel-data ww-current-panel))))))
	     (ww-execute-command (concat "echo == GIT diff for \\'" escaped-filename "\\': ==; git diff " escaped-filename " | colordiff | diff-highlight") 3))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-u")
	   (let ((escaped-filename (ww-escape-filename (car (ww-get-selected-file (aref ww-panel-data ww-current-panel))))))
	     (ww-execute-command (concat "echo == Adding file \\'" escaped-filename "\\' to GIT: ==; git add " escaped-filename "; echo == GIT status: ==; git status") 4))
	   (setq ww-current-dialog nil))
	  ((equal char "\C-l")
	   (ww-execute-command "echo == GIT status: ==; git status" 3)
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward command-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back command-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word command-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word command-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home command-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end command-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line command-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char command-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word command-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back command-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back command-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\t") (equal char "\C-o")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert command-line-edit char))))
  (if ww-current-dialog (ww-draw-custom-command-dialog t) (ww-redraw))
  )

(defun ww-process-make-symlink-dialog (char)
  "Process make symlink dialog"

  (let* ((input-focus (aref ww-current-dialog-data 6))
	 (source-line-edit (aref ww-current-dialog-data 4))
	 (destination-line-edit (aref ww-current-dialog-data 5))
	 (focused-line-edit (if (equal input-focus 0) source-line-edit destination-line-edit))
	 (work-dir (aref ww-current-dialog-data 6))
	 (source (aref source-line-edit 4))
	 (destination (aref destination-line-edit 4)))
    (cond ((or (equal char "\t") (equal char "\C-o"))
	   (aset ww-current-dialog-data 6 (if (equal input-focus 0) 1 0)))
	  ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   (ww-make-symlink source destination)
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward focused-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back focused-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word focused-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word focused-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home focused-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end focused-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line focused-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char focused-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word focused-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back focused-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back focused-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\t") (equal char "\C-o")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert focused-line-edit char))))
  (if ww-current-dialog (ww-draw-make-symlink-dialog t) (ww-redraw))
  )

(defun ww-process-mark-dialog (char)
  "Process mark dialog"

  (let* ((mask-line-edit (aref ww-current-dialog-data 4))
	 (work-dir (aref ww-current-dialog-data 5))
	 (mark (aref ww-current-dialog-data 6))
	 (mask (aref (aref ww-current-dialog-data 4) 4)))
    (cond ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char [enter]))
	   (ww-mark-files mark mask)
	   (setq ww-current-dialog nil))
	  ((equal char "\C-f")
	   (ww-le-forward mask-line-edit))
	  ((equal char "\C-b")
	   (ww-le-back mask-line-edit))
	  ((equal char "\033f")
	   (ww-le-forward-word mask-line-edit))
	  ((equal char "\033b")
	   (ww-le-back-word mask-line-edit))
	  ((equal char "\C-a")
	   (ww-le-home mask-line-edit))
	  ((equal char "\C-e")
	   (ww-le-end mask-line-edit))
	  ((equal char "\C-k")
	   (ww-le-kill-line mask-line-edit))
	  ((equal char "\C-d")
	   (ww-le-kill-char mask-line-edit))
	  ((equal char "\033d")
	   (ww-le-kill-word mask-line-edit))
	  ((or (equal char "\10") (equal char "\177"))
	   (ww-le-kill-char-back mask-line-edit))
	  ((equal char "\C-w")
	   (ww-le-kill-word-back mask-line-edit))
	  ((or (equal char "\C-p") (equal char "\C-n")
	       (equal char "\C-v") (equal char "\033v")
	       (equal char "\t") (equal char "\C-o")
	       (equal char "\033a")
	       (equal char "\033e")) ;; TODO: What's that??
	   nil) ;; Crap collector
	  ((not (or (equal char "\0") (equal char "\31") (equal char "\33")))
	   (ww-le-insert mask-line-edit char))))
  (if ww-current-dialog (ww-draw-mark-dialog t) (ww-redraw))
  )

(defun ww-process-current-dialog (char)
  "Process current dialog"
  
  (cond
   ;; Global bindings
   ((equal char "\C-g")
    (setq ww-current-dialog nil)
    (ww-redraw))
   ;; Dialog-specific processing
   ((= ww-current-dialog 0)
    (ww-process-rename-dialog char))
   ((= ww-current-dialog 1)
    (ww-process-remove-dialog char))
   ((= ww-current-dialog 2)
    (ww-process-copy-dialog char))
   ((= ww-current-dialog 3)
    (ww-process-make-directory-dialog char))
   ((= ww-current-dialog 4)
    (ww-process-mark-dialog char))
   ((= ww-current-dialog 5)
    (ww-process-make-symlink-dialog char))
   ((= ww-current-dialog 6)
    (ww-process-custom-command-dialog char)))
  )

(defun ww-rename (source destination)
  "Rename SOURCE to DESTINATION"

  (print (concat "RENAME: " source " -> " destination) t)
  )

(defun ww-returning-perl-script-sentinel (proc msg)
  "Sentinel for perl script buffers.
The purpose is to get rid of the local keymap,
print status info and switch buffer if needed."

  (let ((buffer (process-buffer proc))
	(exit-status (process-exit-status proc)))
    (when (memq (process-status proc) '(signal exit))
      (if (null (buffer-name buffer))
	  (set-process-buffer proc nil)
	(let ((obuf (current-buffer)))
	  ;; save-excursion isn't the right thing if
	  ;; process-buffer is current-buffer
	  (unwind-protect
	      (progn
		(set-buffer buffer)
		(use-local-map nil)
		(goto-char (point-max))
		(if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		(cond ((= exit-status 0)
		       (insert "\n== DONE ==\n\n"))
		      ((= exit-status 1)
		       (insert "\n== UNCLEAN ==\n\n"))
		      ((= exit-status 9)
		       (insert "\n== INTERRUPTED ==\n\n"))
		      (t
		       (insert (format "\n== EXITED WITH SIGNAL %d ==\n== RETURN MESSAGE: %s ==\n\n"
				       exit-status (substring msg 0 (string-match "\n$" msg))))))
		(if (and (not ww-remain-in-buffer-after-exit) (equal buffer obuf)) (werewolf))
		(delete-process proc))
	    (set-buffer obuf)))))))

(defun ww-returning-with-message-term-sentinel (proc msg)
  "Sentinel for term buffers.
The main purpose is to get rid of the local keymap."

  (let ((buffer (process-buffer proc)))
    (when (memq (process-status proc) '(signal exit))
      (if (null (buffer-name buffer))
	  ;; buffer killed
	  (set-process-buffer proc nil)
	(let ((obuf (current-buffer)))
	  ;; save-excursion isn't the right thing if
	  ;; process-buffer is current-buffer
	  (unwind-protect
	      (progn
		;; Write something in the compilation buffer
		;; and hack its mode line.
		(set-buffer buffer)
		;; Get rid of local keymap.
		(use-local-map nil)
		(ww-term-handle-exit (process-name proc) msg)
		(if (equal buffer obuf) (werewolf))
		;; Since the buffer and mode line will show that the
		;; process is dead, we can delete it now.  Otherwise it
		;; will stay around until M-x list-processes.
		(delete-process proc))
	    (set-buffer obuf)))
	))))

(defun ww-with-message-term-sentinel (proc msg)
  "Sentinel for term buffers.
The main purpose is to get rid of the local keymap."

  (let ((buffer (process-buffer proc)))
    (when (memq (process-status proc) '(signal exit))
      (if (null (buffer-name buffer))
	  ;; buffer killed
	  (set-process-buffer proc nil)
	(let ((obuf (current-buffer)))
	  ;; save-excursion isn't the right thing if
	  ;; process-buffer is current-buffer
	  (unwind-protect
	      (progn
		;; Write something in the compilation buffer
		;; and hack its mode line.
		(set-buffer buffer)
		;; Get rid of local keymap.
		(use-local-map nil)
		(ww-term-man-handle-exit (process-name proc) msg)
		;; Since the buffer and mode line will show that the
		;; process is dead, we can delete it now.  Otherwise it
		;; will stay around until M-x list-processes.
		(delete-process proc))
	    (set-buffer obuf)))
	))))

(defun ww-go-home-term-sentinel (proc msg)
  "Sentinel for term buffers.
The main purpose is to get rid of the local keymap."

  (let ((buffer (process-buffer proc)))
    (when (memq (process-status proc) '(signal exit))
      (if (null (buffer-name buffer))
	  ;; buffer killed
	  (set-process-buffer proc nil)
	(let ((obuf (current-buffer)))
	  ;; save-excursion isn't the right thing if
	  ;; process-buffer is current-buffer
	  (unwind-protect
	      (progn
		;; Write something in the compilation buffer
		;; and hack its mode line.
		(set-buffer buffer)
		;; Get rid of local keymap.
		(use-local-map nil)
		(ww-term-handle-exit (process-name proc) msg)
		;; Since the buffer and mode line will show that the
		;; process is dead, we can delete it now.  Otherwise it
		;; will stay around until M-x list-processes.
		(delete-process proc))
	    (set-buffer obuf)))
	))))

(defun ww-process-perl-script-output (proc str)
  (with-current-buffer (process-buffer proc)
    (use-local-map ww-copy-mode-map)
    (setq ww-input-buffer (concat ww-input-buffer str))
    (save-selected-window
      (let ((nl (string-match "\n" ww-input-buffer)))
	(while nl
	  (let* ((at-last-line (= (point-at-bol) (save-excursion (goto-char (point-max)) (point-at-bol))))
		 (message (concat (substring ww-input-buffer 0 nl)))
		 (message-type (substring message 0 1))
		 sep2)
	    (cond ((string-equal message-type "D")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  D: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "L")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  L: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "C")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  C: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "B")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  B: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "P")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  P: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "F")
		   (setq sep2 (or (string-match ":" message 2) 0))
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "  F: " (substring message 2 sep2) " <- " (substring message (1+ sep2))))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  ((string-equal message-type "p")
		   (let ((pos (point)))
		     (cond (at-last-line
			    (goto-char (point-max))
			    (goto-char (point-at-bol))
			    (delete-region (point-at-bol) (min (+ (point-at-bol) 3) (point-at-eol)))
			    (insert (substring (concat "   " (substring message 2)) -3))
			    (goto-char pos))
			   (t
			    (save-excursion
			      (goto-char (point-max))
			      (goto-char (point-at-bol))
			      (delete-region (point-at-bol) (min (+ (point-at-bol) 3) (point-at-eol)))
			      (insert (substring (concat "   " (substring message 2)) -3)))))))
		  ((string-equal message-type "E")
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "ERROR: " (substring message 2)))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol)))))
		  (t
		   (save-excursion
		     (goto-char (point-max))
		     (if (not (= (point-at-bol) (point-at-eol))) (insert "\n"))
		     (insert "UNHANDLED: " message))
		   (cond (at-last-line (goto-char (point-max)) (goto-char (point-at-bol))))))
	    (setq ww-input-buffer (substring ww-input-buffer (+ nl 1)))
	    (setq nl (string-match "\n" ww-input-buffer)))))))
  )

(defun ww-exec-perl-script (buffer name script remain-in-buffer process-filter process-sentinel)
  "Execute Copy Perl script on given buffer"

  (save-excursion
    (set-buffer buffer)
    (let ((proc (get-buffer-process buffer)))	; Blast any old process.
      (when proc (delete-process proc)))
    (erase-buffer)
    ;; Crank up a new process
    (let ((proc (let ((process-connection-type t)
		      (inhibit-eol-conversion t)
		      ;; The process's output contains not just chars but also binary
		      ;; escape codes, so we need to see the raw output.  We will have to
		      ;; do the decoding by hand on the parts that are made of chars.
		      (coding-system-for-read nil)
		      )
		  (apply 'start-process name buffer "perl" nil))))
      (make-local-variable 'ww-remain-in-buffer-after-exit)
      (setq ww-remain-in-buffer-after-exit remain-in-buffer)
      (make-local-variable 'term-ptyp)
      (setq term-ptyp t) ; t if pty, nil if pipe.
      (process-send-string proc script)
      (process-send-eof proc)
      (set-process-filter proc process-filter)
      (set-process-sentinel proc process-sentinel)
      buffer))
  )

(defun ww-copy (wd destination sources)
  "Copy SOURCES to DESTINATION at working directory WD"

  (let* ((script (concat "#!/usr/bin/perl -w\nmy $args = << '';\nnone\n" wd "\n" destination "\n"))
	 (buffer (get-buffer-create "*WEREWOLF-COPY*"))
	 (command-keys (this-command-keys)))
    (set-buffer buffer)
    (make-local-variable 'ww-input-buffer)
    (setq ww-input-buffer "")
    (goto-char (point-max))
    (if (or (string-equal command-keys "\C-j") (string-equal command-keys "\033j")) (switch-to-buffer buffer))
    (while sources
      (setq script (concat script (car sources) "\n"))
      (setq sources (cdr sources)))
    (setq script (concat script ww-copy-perl-script))
    ;; If no process, or nuked process, crank up a new one and put buffer in
    ;; term mode.  Otherwise, leave buffer and existing process alone.
    (cond ((not (term-check-proc buffer))
	   (setq truncate-lines t)
	   (setq default-directory (concat wd "/"))
	   (ww-exec-perl-script buffer "" script (string-equal command-keys "\033j")
				'ww-process-perl-script-output 'ww-returning-perl-script-sentinel))))
  )

(defun ww-rename (wd destination sources)
  "Rename SOURCES to DESTINATION at working directory WD"

  (let* ((script (concat "#!/usr/bin/perl -w\nmy $args = << '';\nnone\n" wd "\n" destination "\n"))
	 (buffer (get-buffer-create "*WEREWOLF-RENAME*"))
	 (command-keys (this-command-keys)))
    (set-buffer buffer)
    (make-local-variable 'ww-input-buffer)
    (setq ww-input-buffer "")
    (goto-char (point-max))
    (if (or (string-equal command-keys "\C-j") (string-equal command-keys "\033j")) (switch-to-buffer buffer))
    (while sources
      (setq script (concat script (car sources) "\n"))
      (setq sources (cdr sources)))
    (setq script (concat script ww-rename-perl-script))
    ;; If no process, or nuked process, crank up a new one and put buffer in
    ;; term mode.  Otherwise, leave buffer and existing process alone.
    (cond ((not (term-check-proc buffer))
	   (setq truncate-lines t)
	   (setq default-directory (concat wd "/"))
	   (ww-exec-perl-script buffer "" script (string-equal command-keys "\033j")
				'ww-process-perl-script-output 'ww-returning-perl-script-sentinel))))
  )

(defun ww-make-directory (directory)
  "Make directory DIRECTORY"

  (make-directory directory t)
  (ww-panel-reread ww-current-panel)
  (ww-enter-dir (ww-expand-filename "." (aref (aref ww-panel-data ww-current-panel) 1)) directory)
  )

(defun ww-make-symlink (source destination)
  "Make symbolic link at DESTINATION pointing to SOURCE"

  (make-symbolic-link source destination)
  (ww-panel-reread 0)
  (ww-panel-reread 1)
  )

(defun ww-mark-files (mark mask)
  "Mark/unmark files"

  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (inode)
	 (mask-regexp (wildcard-to-regexp mask)))
    (while dirs
      (setq inode (car dirs))
      (if (string-match mask-regexp (car inode)) (setcdr inode (cons mark (cddr inode))))
      (setq dirs (cdr dirs)))
    (while files
      (setq inode (car files))
      (if (string-match mask-regexp (car inode)) (setcdr inode (cons mark (cddr inode))))
      (setq files (cdr files))))
  (ww-redraw)
  )

(defun ww-remove (wd inodes)
  "Remove inodes INODES at working directory WD"

  (let* ((script (concat "#!/usr/bin/perl -w\nmy $args = << '';\nnone\n" wd "\n"))
	 (buffer (get-buffer-create "*WEREWOLF-REMOVE*"))
	 (command-keys (this-command-keys)))
    (set-buffer buffer)
    (make-local-variable 'ww-input-buffer)
    (goto-char (point-max))
    (if (or (string-equal command-keys "\C-j") (string-equal command-keys "\033j")) (switch-to-buffer buffer))
    (while inodes
      (setq script (concat script (car inodes) "\n"))
      (setq inodes (cdr inodes)))
    (setq script (concat script ww-remove-perl-script))
    ;; If no process, or nuked process, crank up a new one and put buffer in
    ;; term mode.  Otherwise, leave buffer and existing process alone.
    (cond ((not (term-check-proc buffer))
	   (setq default-directory (concat wd "/"))
	   (ww-exec-perl-script buffer "" script (string-equal command-keys "\033j")
				'ww-process-perl-script-output 'ww-returning-perl-script-sentinel))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Line edit processing functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ww-le-draw (line-edit)
  "Line edit: draw"

  (let* ((row (aref line-edit 0))
	 (col (aref line-edit 1))
	 (w (aref line-edit 2))
	 (work-w (1- w))
	 (prop (aref line-edit 3))
	 (text (aref line-edit 4))
	 (off (aref line-edit 5))
	 (voff (aref line-edit 6))
	 (work-text (substring text voff (min (+ work-w voff) (length text)))))
    (ww-clear-string row col w prop)
    (ww-put-string row col work-text prop)
    (ww-put-cursor row (+ col (- off voff))))
  )

(defun ww-le-place-cursor (line-edit)
  "Line edit: place cursor"

  (let ((row (aref line-edit 0))
	(col (aref line-edit 1))
	(off (aref line-edit 5))
	(voff (aref line-edit 6)))
    (ww-put-cursor row (+ col (- off voff))))
  )

(defun ww-le-forward (line-edit)
  "Line edit: forward"

  (let ((work-w (1- (aref line-edit 2)))
	(off (min (1+ (aref line-edit 5)) (length (aref line-edit 4))))
	(voff (aref line-edit 6)))
    (aset line-edit 5 off)
    (if (< voff (- off work-w))
	(aset line-edit 6 (1+ voff))))
  )

(defun ww-le-back (line-edit)
  "Line edit: back"

  (let ((off (max (1- (aref line-edit 5)) 0))
	(voff (aref line-edit 6)))
    (aset line-edit 5 off)
    (if (> voff off)
	(aset line-edit 6 off)))
  )

(defun ww-le-home (line-edit)
  "Line edit: home"

  (aset line-edit 5 0)
  (aset line-edit 6 0)
  )

(defun ww-le-end (line-edit)
  "Line edit: end"

  (let ((len (length (aref line-edit 4))))
    (aset line-edit 5 len)
    (aset line-edit 6 (max (- len (aref line-edit 2) -1) 0)))
  )

(defun ww-le-insert (line-edit char)
  "Line edit: insert character"

  (let ((work-w (1- (aref line-edit 2)))
	(text (aref line-edit 4))
	(off (aref line-edit 5))
	(voff (aref line-edit 6)))
    (aset line-edit 4 (concat (substring text 0 off) char (substring text off (length text))))
    (setq off (1+ off))
    (aset line-edit 5 off)
    (if (> (- off voff) work-w)
	(aset line-edit 6 (1+ voff))))
  )

(defun ww-le-insert-string (line-edit str)
  "Line edit: insert string"

  (let ((work-w (1- (aref line-edit 2)))
	(text (aref line-edit 4))
	(off (aref line-edit 5)))
    (aset line-edit 4 (concat (substring text 0 off) str (substring text off)))
    (setq off (+ off (length str)))
    (aset line-edit 5 off)
    (if (< (aref line-edit 6) (- off work-w)) (aset line-edit 6 (- off work-w))))
  )

(defun ww-le-clear (line-edit)
  "Line edit: clear"

  (aset line-edit 4 "")
  (aset line-edit 5 0)
  (aset line-edit 6 0)
  )

(defun ww-le-save-clear (line-edit)
  "Line edit: save history and clear (if value isn't equal to last saved one)"

  (let ((new-value (aref line-edit 4)))
    (unless (equal new-value (car (aref line-edit 7))) (aset line-edit 7 (cons new-value (aref line-edit 7)))))
  (aset line-edit 8 0)
  (aset line-edit 4 "")
  (aset line-edit 5 0)
  (aset line-edit 6 0)
  )

(defun ww-le-history-previous (line-edit)
  "Line edit: set previous history entry to line"

  (let ((pos (aset line-edit 8 (min (length (aref line-edit 7)) (1+ (aref line-edit 8))))))
    (aset line-edit 4 (if (> pos 0) (nth (1- pos) (aref line-edit 7)) ""))
    (aset line-edit 5 0)
    (aset line-edit 6 0))
  )
  
(defun ww-le-history-next (line-edit)
  "Line edit: set next history entry to line"

  (let ((pos (aset line-edit 8 (max 0 (1- (aref line-edit 8))))))
    (aset line-edit 4 (if (> pos 0) (nth (1- pos) (aref line-edit 7)) ""))
    (aset line-edit 5 0)
    (aset line-edit 6 0))
  )


(defun ww-le-kill-line (line-edit)
  "Line edit: kill line"

  (aset line-edit 4 (substring (aref line-edit 4) 0 (aref line-edit 5)))
  )

(defun ww-le-kill-char (line-edit)
  "Line edit: kill char"

  (let* ((text (aref line-edit 4))
	 (len (length text))
	 (off (aref line-edit 5)))
    (aset line-edit 4 (concat (substring text 0 off) (substring text (min (1+ off) len) len))))
  )

(defun ww-le-kill-word (line-edit)
  "Line edit: kill word"

  (let* ((work-w (1- (aref line-edit 2)))
	 (text (aref line-edit 4))
	 (len (length text))
	 (start-off (aref line-edit 5))
	 (off (if (string-match "[ \t\r\n\f\v]*[^ \t\r\n\f\v]*" text start-off) (match-end 0) start-off))
	 (voff (aref line-edit 6)))
    (aset line-edit 4 (concat (substring text 0 start-off) (substring text (min off len) len))))
  )

(defun ww-le-kill-char-back (line-edit)
  "Line edit: kill char back"

  (let ((text (aref line-edit 4))
	(off (aref line-edit 5))
	(voff (aref line-edit 6)))
    (if (> off 0)
	(progn
	  (aset line-edit 4 (concat (substring text 0 (1- off)) (substring text off (length text))))
	  (setq off (1- off))
	  (aset line-edit 5 off)
	  (if (> voff off) (aset line-edit 6 off)))))
  )

(defun ww-le-kill-word-back (line-edit)
  "Line edit: kill word back"

  (let* ((text (aref line-edit 4))
	 (end-off (aref line-edit 5))
	 (off (or (string-match "[^ \t\r\n\f\v]*[ \t\r\n\f\v]*$"
				(substring text 0 end-off)) end-off))
	 (voff (aref line-edit 6)))
    (aset line-edit 4 (concat (substring text 0 off) (substring text end-off (length text))))
    (aset line-edit 5 off)
    (if (> voff off) (aset line-edit 6 off)))
  )

(defun ww-le-forward-word (line-edit)
  "Line edit: forward word"

  (let ((work-w (1- (aref line-edit 2)))
	(off (if (string-match "[ \t\r\n\f\v]*[^ \t\r\n\f\v]*" (aref line-edit 4) (aref line-edit 5))
		 (match-end 0) (aref line-edit 5)))
	(voff (aref line-edit 6)))
    (aset line-edit 5 off)
    (if (< voff (- off work-w)) (aset line-edit 6 (- off work-w))))
  )

(defun ww-le-back-word (line-edit)
  "Line edit: back word"

  (let ((off (or (string-match "[^ \t\r\n\f\v]*[ \t\r\n\f\v]*$"
			       (substring (aref line-edit 4) 0 (aref line-edit 5))) (aref line-edit 5)))
	(voff (aref line-edit 6)))
    (aset line-edit 5 off)
    (if (> voff off) (aset line-edit 6 off)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-interactive (indirect) input handlers ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ww-mark ()
  "Mark"

  (setq ww-search-string nil)
  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (current (aref panel-data 4))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (count (caddr inodes))
	 (inode (if (< current (length dirs)) (nth current dirs) (nth (- current (length dirs)) files))))
    (if inode (setcdr inode (cons (not (cadr inode)) (cddr inode))))
    (if (< current (1- count)) (ww-switch-to-file current (1+ current)) (ww-switch-to-file current current)))
  )

(defun ww-mark-invert ()
  "Invert marking inside panel"

  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (inode))
    (while dirs
      (setq inode (car dirs))
      (setcdr inode (cons (not (cadr inode)) (cddr inode)))
      (setq dirs (cdr dirs)))
    (while files
      (setq inode (car files))
      (setcdr inode (cons (not (cadr inode)) (cddr inode)))
      (setq files (cdr files))))
  (ww-redraw)
  )

(defun ww-up ()
  "Up"

  (setq ww-search-string nil)
  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (current (aref panel-data 4)))
    (if (> current 0)
	(ww-switch-to-file current (1- current))))
  )

(defun ww-down ()
  "Down"

  (setq ww-search-string nil)
  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (current (aref panel-data 4))
	 (count (caddr (aref panel-data 2))))
    (if (< current (1- count))
	(ww-switch-to-file current (1+ current))))
  )

(defun ww-page-up ()
  "Page up"

  (setq ww-search-string nil)
  (let ((panel-data (aref ww-panel-data ww-current-panel)))
    (aset panel-data 4 (- (aref panel-data 4)
			  (aref (aref ww-panel-metrics ww-current-panel) 2)))
    (cond ((< (aref panel-data 4) 0) (aset panel-data 4 0))))
  (ww-redraw)
  )

(defun ww-page-down ()
  "Page down"

  (setq ww-search-string nil)
  (let ((panel-data (aref ww-panel-data ww-current-panel)))
    (aset panel-data 4 (+ (aref panel-data 4)
			  (aref (aref ww-panel-metrics ww-current-panel) 2)))
    (let ((count (caddr (aref panel-data 2))))
      (cond ((>= (aref panel-data 4) count)
	     (aset panel-data 4 (1- count))))))
  (ww-redraw)
  )

(defun ww-on-top ()
  "On top"

  (setq ww-search-string nil)
  (aset (aref ww-panel-data ww-current-panel) 4 0)
  (ww-redraw)
  )

(defun ww-to-bottom ()
  "To bottom"

  (setq ww-search-string nil)
  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (count (1- (caddr (aref panel-data 2)))))
    (aset panel-data 4 (if (>= count 0) count 0)))
  (ww-redraw)
  )


(defun ww-enter ()
  "Enter"

  (setq ww-search-string nil)
  (if (> (length (aref ww-command-line 4)) 0)
      (let ((command (aref ww-command-line 4)))
	(ww-le-save-clear ww-command-line)
	(ww-redraw)
	(ww-execute-command command (ww-get-buffer-switch-mode (this-command-keys))))
    (let* ((panel-data (aref ww-panel-data ww-current-panel))
	   (wd (aref panel-data 1))
	   (inodes (aref panel-data 2))
	   (selected (aref panel-data 4))
	   (i 0)
	   (dirs (car inodes))
	   (files (cadr inodes))
	   (continue t))
      (while (and dirs continue)
	(cond ((= i selected)
	       (ww-enter-dir (ww-expand-filename (caar dirs) wd))
	       (ww-refresh)
	       (setq continue nil)))
	(setq i (1+ i))
	(setq dirs (cdr dirs)))
      (while (and files continue)
	(cond ((= i selected)
	       (ww-enter-file (ww-expand-filename (caar files) wd))
	       (setq continue nil)))
	(setq i (1+ i))
	(setq files (cdr files)))))
  )

(defun ww-enter-man ()
  "Get man page for given arguments"

  (setq ww-search-string nil)
  (if (> (length (aref ww-command-line 4)) 0)
      (let ((command (aref ww-command-line 4)))
	;; (ww-le-save-clear ww-command-line)
	(ww-redraw)
	(ww-execute-command (concat "man -P cat " command) 4)))
  )

(defun ww-enter-no-exec-read-only ()
  "Enter (never execute, read only)"

  (setq ww-search-string nil)
  (if (> (length (aref ww-command-line 4)) 0)
      (let ((command (aref ww-command-line 4)))
	(ww-le-save-clear ww-command-line)
	(ww-redraw)
	(ww-execute-command command (ww-get-buffer-switch-mode (this-command-keys))))
    (let* ((panel-data (aref ww-panel-data ww-current-panel))
	   (wd (aref panel-data 1))
	   (inodes (aref panel-data 2))
	   (selected (aref panel-data 4))
	   (i 0)
	   (dirs (car inodes))
	   (files (cadr inodes))
	   (continue t))
      (while dirs
	(setq i (1+ i))
	(setq dirs (cdr dirs)))
      (while (and files continue)
	(cond ((= i selected)
	       (ww-enter-file-no-exec (ww-expand-filename (caar files) wd) t)
	       (setq continue nil)))
	(setq i (1+ i))
	(setq files (cdr files)))
      (ww-refresh)))
  )

(defun ww-enter-no-exec ()
  "Enter (never execute)"

  (setq ww-search-string nil)
  (if (> (length (aref ww-command-line 4)) 0)
      (let ((command (aref ww-command-line 4)))
	(ww-le-save-clear ww-command-line)
	(ww-redraw)
	(ww-execute-command command (ww-get-buffer-switch-mode (this-command-keys))))
    (let* ((panel-data (aref ww-panel-data ww-current-panel))
	   (wd (aref panel-data 1))
	   (inodes (aref panel-data 2))
	   (selected (aref panel-data 4))
	   (i 0)
	   (dirs (car inodes))
	   (files (cadr inodes))
	   (continue t))
      (while dirs
	(setq i (1+ i))
	(setq dirs (cdr dirs)))
      (while (and files continue)
	(cond ((= i selected)
	       (ww-enter-file-no-exec (ww-expand-filename (caar files) wd) nil)
	       (setq continue nil)))
	(setq i (1+ i))
	(setq files (cdr files)))
      (ww-refresh)))
  )

(defun ww-level-up ()
  "Level up"

  (setq ww-search-string nil)
  (ww-enter-dir (ww-expand-filename
		 ".." (aref (aref ww-panel-data ww-current-panel) 1))
		(aref (aref ww-panel-data ww-current-panel) 1))
  (ww-redraw)
  )

(defun ww-command-line-back ()
  "Command line move back"

  (setq buffer-read-only nil)
  (ww-le-back ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-back-word ()
  "Command line move back on a word"

  (setq buffer-read-only nil)
  (ww-le-back-word ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-forward ()
  "Command line move forward"

  (setq buffer-read-only nil)
  (ww-le-forward ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-forward-word ()
  "Command line move forward on a word"

  (setq buffer-read-only nil)
  (ww-le-forward-word ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-home ()
  "Command line move home"

  (setq buffer-read-only nil)
  (ww-le-home ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-end ()
  "Command line move end"

  (setq buffer-read-only nil)
  (ww-le-end ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-kill-line ()
  "Command line kill resto of line"

  (setq buffer-read-only nil)
  (ww-le-kill-line ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-kill-char ()
  "Command line kill next char"

  (setq buffer-read-only nil)
  (ww-le-kill-char ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-kill-word ()
  "Command line kill next word"

  (setq buffer-read-only nil)
  (ww-le-kill-word ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-kill-word-back ()
  "Command line kill previous word"

  (setq buffer-read-only nil)
  (ww-le-kill-word-back ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-previous ()
  "Set previous command from history"

  (setq buffer-read-only nil)
  (ww-le-history-previous ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-line-next ()
  "Enter previous command from history"

  (setq buffer-read-only nil)
  (ww-le-history-next ww-command-line)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-draw-command-line (&optional clear)
  "Drawing command line"

  (setq buffer-read-only nil)
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-file-to-command-line ()
  "Put current directory to command line"

  (setq buffer-read-only nil)
  (ww-le-insert-string ww-command-line (concat (ww-escape-filename
						(car (ww-get-selected-file (aref ww-panel-data ww-current-panel)))) " "))
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-command-current-directory-to-command-line ()
  "Put current directory to command line"

  (setq buffer-read-only nil)
  (ww-le-insert-string ww-command-line (concat (ww-escape-filename (aref (aref ww-panel-data ww-current-panel) 1)) "/"))
  (ww-le-draw ww-command-line)
  (setq buffer-read-only t)
  )

(defun ww-switch-panel ()
  "Switch panel"

  (setq ww-search-string nil)
  (setq ww-current-panel (mod (1+ ww-current-panel) 2))
  (setq default-directory (concat (aref (aref ww-panel-data ww-current-panel) 1) "/"))
  (ww-redraw)
  )

(defun ww-wd-to-other-panel ()
  "Work dir to other panel"

  (let ((this ww-current-panel)
	(other (mod (1+ ww-current-panel) 2)))
    (setq ww-current-panel other)
    (ww-enter-dir (aref (aref ww-panel-data this) 1))
    (setq ww-current-panel this))
  (ww-refresh t)
  )

(defun ww-search-mode ()
  "Enter search mode"

  (setq ww-search-string "")
  (ww-redraw)
  )

(defun ww-rename-mode ()
  "Enter rename mode (rename dialog)"

  (setq ww-current-dialog 0)
  (setq ww-current-dialog-data (make-vector 9 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - input focus (0 - source, else - destination)
  ;; 5 - source line edit
  ;; 6 - destination line edit
  ;; 7 - source inode list
  ;; 8 - source inode count
  (aset ww-current-dialog-data 4 0)
  (aset ww-current-dialog-data 5 (make-vector 9 nil))
  (aset ww-current-dialog-data 6 (make-vector 9 nil))
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 10)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (source-line-edit (aref ww-current-dialog-data 5))
	 (destination-line-edit (aref ww-current-dialog-data 6))
	 (prop-line-edit '(face ww-face-dialog-line-edit))
	 (panel-data (aref ww-panel-data ww-current-panel))
	 (wd (aref panel-data 1))
	 (inodes (aref panel-data 2))
	 (selected (aref panel-data 4))
	 (i 0)
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (continue t)
	 (targets-packed (ww-get-marked))
	 (target-count (car targets-packed))
	 (targets (cdr targets-packed))
	 (source-file (if targets "*" (or (car (ww-get-selected-file panel-data)) "")))
	 (destination-file (aref (aref ww-panel-data (mod (1+ ww-current-panel) 2)) 1)))
    
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset source-line-edit 0 (+ y 3))
    (aset source-line-edit 1 (+ x 3))
    (aset source-line-edit 2 (- w 6))
    (aset source-line-edit 3 prop-line-edit)
    (aset source-line-edit 4 source-file)
    (aset source-line-edit 5 0)
    (aset source-line-edit 6 0)
    (aset source-line-edit 7 (make-list 0 nil))
    (aset source-line-edit 8 0)
    (aset destination-line-edit 0 (+ y 6))
    (aset destination-line-edit 1 (+ x 3))
    (aset destination-line-edit 2 (- w 6))
    (aset destination-line-edit 3 prop-line-edit)
    (aset destination-line-edit 4 destination-file)
    (aset destination-line-edit 5 0)
    (aset destination-line-edit 6 0)
    (aset destination-line-edit 7 (make-list 0 nil))
    (aset destination-line-edit 8 0)
    (aset ww-current-dialog-data 7 targets)
    (aset ww-current-dialog-data 8 target-count))
  (ww-redraw)
  )

(defun ww-copy-mode ()
  "Enter copy mode (copy dialog)"

  (setq ww-current-dialog 2)
  (setq ww-current-dialog-data (make-vector 9 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - input focus (0 - source, else - destination)
  ;; 5 - source line edit
  ;; 6 - destination line edit
  ;; 7 - source inode list
  ;; 8 - source inode count
  (aset ww-current-dialog-data 4 0)
  (aset ww-current-dialog-data 5 (make-vector 9 nil))
  (aset ww-current-dialog-data 6 (make-vector 9 nil))
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 10)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (source-line-edit (aref ww-current-dialog-data 5))
	 (destination-line-edit (aref ww-current-dialog-data 6))
	 (prop-line-edit '(face ww-face-dialog-line-edit))
	 (panel-data (aref ww-panel-data ww-current-panel))
	 (wd (aref panel-data 1))
	 (inodes (aref panel-data 2))
	 (selected (aref panel-data 4))
	 (i 0)
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (continue t)
	 (targets-packed (ww-get-marked))
	 (target-count (car targets-packed))
	 (targets (cdr targets-packed))
	 (source-file (if targets "*" (or (car (ww-get-selected-file panel-data)) "")))
	 (destination-file (aref (aref ww-panel-data (mod (1+ ww-current-panel) 2)) 1)))
    
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset source-line-edit 0 (+ y 3))
    (aset source-line-edit 1 (+ x 3))
    (aset source-line-edit 2 (- w 6))
    (aset source-line-edit 3 prop-line-edit)
    (aset source-line-edit 4 source-file)
    (aset source-line-edit 5 0)
    (aset source-line-edit 6 0)
    (aset source-line-edit 7 (make-list 0 nil))
    (aset source-line-edit 8 0)
    (aset destination-line-edit 0 (+ y 6))
    (aset destination-line-edit 1 (+ x 3))
    (aset destination-line-edit 2 (- w 6))
    (aset destination-line-edit 3 prop-line-edit)
    (aset destination-line-edit 4 destination-file)
    (aset destination-line-edit 5 0)
    (aset destination-line-edit 6 0)
    (aset destination-line-edit 7 (make-list 0 nil))
    (aset destination-line-edit 8 0)
    (aset ww-current-dialog-data 7 targets)
    (aset ww-current-dialog-data 8 target-count))
  (ww-redraw)
  )

(defun ww-make-directory-mode ()
  "Enter make directory mode (make directory dialog)"

  (setq ww-current-dialog 3)
  (setq ww-current-dialog-data (make-vector 6 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - directory line edit
  ;; 5 - working directory
  (aset ww-current-dialog-data 4 (make-vector 9 nil))
  (aset ww-current-dialog-data 5 (aref (aref ww-panel-data ww-current-panel) 1))
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 7)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (directory-line-edit (aref ww-current-dialog-data 4))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset directory-line-edit 0 (+ y 3))
    (aset directory-line-edit 1 (+ x 3))
    (aset directory-line-edit 2 (- w 6))
    (aset directory-line-edit 3 prop-line-edit)
    (aset directory-line-edit 4 "")
    (aset directory-line-edit 5 0)
    (aset directory-line-edit 6 0)
    (aset directory-line-edit 7 (make-list 0 nil))
    (aset directory-line-edit 8 0))
  (ww-redraw)
  )

(defun ww-custom-command-mode ()
  "Enter custom command mode (custom command dialog)"

  (setq ww-current-dialog 6)
  (setq ww-current-dialog-data (make-vector 6 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - directory line edit
  ;; 5 - working directory
  (aset ww-current-dialog-data 4 (make-vector 9 nil))
  (aset ww-current-dialog-data 5 (aref (aref ww-panel-data ww-current-panel) 1))
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 7)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (command-line-edit (aref ww-current-dialog-data 4))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset command-line-edit 0 (+ y 3))
    (aset command-line-edit 1 (+ x 3))
    (aset command-line-edit 2 (- w 6))
    (aset command-line-edit 3 prop-line-edit)
    (aset command-line-edit 4 "")
    (aset command-line-edit 5 0)
    (aset command-line-edit 6 0)
    (aset command-line-edit 7 (make-list 0 nil))
    (aset command-line-edit 8 0))
  (ww-redraw)
  )

(defun ww-make-symlink-mode ()
  "Enter make symlink mode (make symlink dialog)"

  (setq ww-current-dialog 5)
  (setq ww-current-dialog-data (make-vector 8 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - source line edit
  ;; 5 - destination line edit
  ;; 6 - current line edit
  ;; 7 - working directory
  (aset ww-current-dialog-data 4 (make-vector 9 nil))
  (aset ww-current-dialog-data 5 (make-vector 9 nil))
  (aset ww-current-dialog-data 6 1)
  (aset ww-current-dialog-data 7 (aref (aref ww-panel-data ww-current-panel) 1))
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 10)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (panel-data (aref ww-panel-data ww-current-panel))
	 (source-file (car (ww-get-selected-file panel-data)))
	 (source-dir (aref panel-data 1))
	 (dest-dir (aref (aref ww-panel-data (if (= ww-current-panel 0) 1 0)) 1))
	 (wd (aref panel-data 1))
	 (source-line-edit (aref ww-current-dialog-data 4))
	 (destination-line-edit (aref ww-current-dialog-data 5))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset source-line-edit 0 (+ y 3))
    (aset source-line-edit 1 (+ x 3))
    (aset source-line-edit 2 (- w 6))
    (aset source-line-edit 3 prop-line-edit)
    (aset source-line-edit 4 (concat (if (equal source-dir "/") "" source-dir) "/" source-file))
    (aset source-line-edit 5 0)
    (aset source-line-edit 6 0)
    (aset source-line-edit 7 (make-list 0 nil))
    (aset source-line-edit 8 0)
    (aset destination-line-edit 0 (+ y 6))
    (aset destination-line-edit 1 (+ x 3))
    (aset destination-line-edit 2 (- w 6))
    (aset destination-line-edit 3 prop-line-edit)
    (aset destination-line-edit 4 (concat (if (equal dest-dir "/") "" dest-dir) "/" source-file))
    (aset destination-line-edit 5 0)
    (aset destination-line-edit 6 0)
    (aset destination-line-edit 7 (make-list 0 nil))
    (aset destination-line-edit 8 0))
  (ww-redraw)
  )

(defun ww-mark-mode (mark)
  "Enter mark/unmark mode (mark/unmark dialog)"

  (setq ww-current-dialog 4)
  (setq ww-current-dialog-data (make-vector 7 nil))
  ;; 0 - width
  ;; 1 - height
  ;; 2 - x
  ;; 3 - y
  ;; 4 - mask line edit
  ;; 5 - working directory
  ;; 6 - mark (t - mark, nil - unmark)
  (aset ww-current-dialog-data 4 (make-vector 9 nil))
  (aset ww-current-dialog-data 5 (aref (aref ww-panel-data ww-current-panel) 1))
  (aset ww-current-dialog-data 6 mark)
  ;; 0 - row
  ;; 1 - column
  ;; 2 - width
  ;; 3 - text property
  ;; 4 - text
  ;; 5 - offset
  ;; 6 - visual offset
  (let* ((win-w (aref ww-window-metrics 1))
	 (win-h (aref ww-window-metrics 0))
	 (w (/ (* win-w 3) 4))
	 (h 7)
	 (x (/ (- win-w w) 2))
	 (y (max (- (/ (- win-h h) 2) 5) 0))
	 (mask-line-edit (aref ww-current-dialog-data 4))
	 (prop-line-edit '(face ww-face-dialog-line-edit)))
    (aset ww-current-dialog-data 0 w)
    (aset ww-current-dialog-data 1 h)
    (aset ww-current-dialog-data 2 x)
    (aset ww-current-dialog-data 3 y)
    (aset mask-line-edit 0 (+ y 3))
    (aset mask-line-edit 1 (+ x 3))
    (aset mask-line-edit 2 (- w 6))
    (aset mask-line-edit 3 prop-line-edit)
    (aset mask-line-edit 4 "*")
    (aset mask-line-edit 5 0)
    (aset mask-line-edit 6 0)
    (aset mask-line-edit 7 (make-list 0 nil))
    (aset mask-line-edit 8 0))
  (ww-redraw)
  )

(defun ww-get-inode (panel)

  (let* ((panel-data (aref ww-panel-data panel))
	 (current (aref (aref ww-panel-data panel) 4))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes)))
    (if (< current (length dirs))
	(nth current dirs)
      (progn
	(setq current (- current (length dirs)))
	(if (< current (length files)) (nth current files)))))
  )

(defun ww-get-marked ()
  "Return list of marked inodes"

  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (current (aref (aref ww-panel-data ww-current-panel) 4))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (selected)
	 (targets)
	 (i 0)
	 (marked-count 0))
    (while dirs
      (setq inode (car dirs))
      (if (= current i) (setq selected (car inode)))
      (if (cadr inode) (progn (setq targets (cons (car inode) targets))
			      (setq marked-count (1+ marked-count))))
      (setq i (1+ i))
      (setq dirs (cdr dirs)))
    (while files
      (setq inode (car files))
      (if (= current i) (setq selected (car inode)))
      (if (cadr inode) (progn (setq targets (cons (car inode) targets))
			      (setq marked-count (1+ marked-count))))
      (setq i (1+ i))
      (setq files (cdr files)))
    (cons marked-count targets))
  )

(defun ww-get-selected-or-marked ()
  "Return list of marked inodes or selected inode
if nothing is marked"

  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (current (aref (aref ww-panel-data ww-current-panel) 4))
	 (inodes (aref panel-data 2))
	 (dirs (car inodes))
	 (files (cadr inodes))
	 (selected)
	 (targets)
	 (i 0))
    (while dirs
      (setq inode (car dirs))
      (if (= current i) (setq selected (car inode)))
      (if (cadr inode) (setq targets (cons (car inode) targets)))
      (setq i (1+ i))
      (setq dirs (cdr dirs)))
    (while files
      (setq inode (car files))
      (if (= current i) (setq selected (car inode)))
      (if (cadr inode) (setq targets (cons (car inode) targets)))
      (setq i (1+ i))
      (setq files (cdr files)))
    (if (and (not targets) selected) (setq targets (cons selected targets)))
    targets))

(defun ww-remove-mode ()
  "Enter remove mode (remove dialog)"

  (let* ((panel-data (aref ww-panel-data ww-current-panel))
	 (wd (aref panel-data 1))
	 (targets (ww-get-selected-or-marked)))
    (if targets
	(let* ((win-w (aref ww-window-metrics 1))
	       (win-h (aref ww-window-metrics 0))
	       (w (/ (* win-w 3) 4))
	       (h 7)
	       (x (/ (- win-w w) 2))
	       (y (max (- (/ (- win-h h) 2) 5) 0))
	       (prop-line-edit '(face ww-face-dialog-line-edit)))
	  (setq ww-current-dialog 1)
	  (setq ww-current-dialog-data (make-vector 6 nil))
	  ;; 0 - width
	  ;; 1 - height
	  ;; 2 - x
	  ;; 3 - y
	  ;; 4 - working directory
	  ;; 5 - inode list
	  (aset ww-current-dialog-data 0 w)
	  (aset ww-current-dialog-data 1 h)
	  (aset ww-current-dialog-data 2 x)
	  (aset ww-current-dialog-data 3 y)
	  (aset ww-current-dialog-data 4 wd)
	  (aset ww-current-dialog-data 5 targets)
	  (ww-redraw))))
  )

(defun ww-cancel-search ()
  "Cancel search mode"

  (setq ww-search-string nil)
  (ww-redraw)
  )

(defun ww-cancel-command ()
  "Cancel command"

  (ww-le-clear ww-command-line)
  (ww-redraw)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactive input handlers ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ww-redraw (&optional panel file-list)
  "Redrawing all the WW screen"
  (interactive)

  (set-buffer ww-buffer-name)
  (ww-update-metrics)
  (let* ((update-left (ww-panel-update-selection 0))
	 (update-right (ww-panel-update-selection 1))
	 (grid-h (1- (aref ww-window-metrics 0)))
	 (grid-w (1- (aref ww-window-metrics 1)))
	 (mid (/ grid-w 2))
	 (partial (and panel (or (and (= panel 0) (not update-left))
				 (and (= panel 1) (not update-right))))))
    (if partial
	(ww-draw-panel-file-pair panel file-list)
      (progn
	;; Clear all
	(setq buffer-read-only nil)
	(delete-region (point-min) (point-max))
	;; Draw statics
	(newline grid-h)
	(loop for i from 1 to (- grid-h 4) do
	      (goto-line i)
	      (move-to-column mid t)
	      (insert ?│))
	(goto-line (- grid-h 3))
	(insert-char ?─ grid-w)
	(goto-line (- grid-h 1))
	(insert-char ?─ grid-w)
	(ww-put-char (- grid-h 4) mid ?┴)
	(goto-line 1)
	(setq buffer-read-only t)
	;; Left panel
	(ww-draw-panel 0)
	;; Right panel
	(ww-draw-panel 1)))
    ;; Status bar and command line
    ;; The 2nd one puts cursor on right place
    (cond (ww-current-dialog
	   (ww-draw-command-line)
	   (ww-draw-status-bar partial)
	   (ww-draw-current-dialog))
	  (ww-search-string
	   (ww-draw-command-line)
	   (ww-draw-status-bar partial))
	  (t
	   (ww-draw-status-bar partial)
	   (ww-draw-command-line))))
  ;; (redisplay t)
  )

(defun ww-refresh (&optional all)
  "Reread and redraw all the WW screen"
  (interactive)

  (set-buffer ww-buffer-name)
  (cond (all
	 (ww-panel-reread 0)
	 (ww-panel-reread 1))
	(t
	 (ww-panel-reread ww-current-panel)))
  (ww-redraw)
  )

(defun ww-input-char ()
  "Some character input"
  (interactive)

  (let ((char (this-command-keys)))
    (cond (ww-current-dialog
	   (ww-process-current-dialog char))
	  ;; Key binding in non-dialog context
	  ((equal char "\C-u") (ww-mark))
	  ((or (equal char [up]) (equal char "\C-p")) (ww-up))
	  ((or (equal char [down]) (equal char "\C-n")) (ww-down))
	  ((or (equal char [prior]) (equal char "\033v")) (ww-page-up))
	  ((or (equal char [next]) (equal char "\C-v")) (ww-page-down))
	  ((or (equal char "\C-j") (equal char "\C-m") (equal char "\033j") (equal char "\033\C-j") (equal char [enter]) (equal char [right]))
	   (ww-enter))
	  ((equal char "\C-x\C-n") (ww-enter-man))
	  ((equal char "\C-q") (ww-custom-command-mode))
	  ((or (equal char "\C-t") (equal char [left])) (ww-level-up))
	  ((equal char "\C-i") (print "Autocompletion: Unimplemented yet..."))
	  ((equal char "\C-z") (suspend-frame))
	  ((equal char "\C-o") (ww-switch-panel))
	  ((equal char "\033o") (ww-wd-to-other-panel))
	  ((equal char "\033<") (ww-on-top))
	  ((equal char "\033>") (ww-to-bottom))
	  ((equal char "\C-s") (ww-search-mode))
	  ((equal char "\C-g") (ww-cancel-search))
	  ((equal char "\C-c") (ww-cancel-command))
	  ((equal char "\C-f") (ww-command-line-forward))
	  ((equal char "\033f") (ww-command-line-forward-word))
	  ((equal char "\C-b") (ww-command-line-back))
	  ((equal char "\033b") (ww-command-line-back-word))
	  ((equal char "\C-a") (ww-command-line-home))
	  ((equal char "\C-e") (ww-command-line-end))
	  ((equal char "\C-k") (ww-command-line-kill-line))
	  ((equal char "\C-d") (ww-command-line-kill-char))
	  ((equal char "\033d") (ww-command-line-kill-word))
	  ((equal char "\C-w") (ww-command-line-kill-word-back))
	  ((equal char "\033p") (ww-command-line-previous))
	  ((equal char "\033n") (ww-command-line-next))
	  ((equal char "\033i") (ww-mark-invert))
	  ((or (equal char "\033h") (equal char "\033\015")) (ww-command-file-to-command-line))
	  ((equal char "\033a") (ww-command-current-directory-to-command-line))
	  ((or (equal char [f1]) (equal char "\033m")) (ww-mark-mode t))
	  ((or (equal char [f2]) (equal char "\033k")) (ww-mark-mode nil))
	  ((equal char [f3]) (ww-enter-no-exec-read-only))
	  ((equal char [f4]) (ww-enter-no-exec))
	  ((equal char [f5]) (ww-copy-mode))
	  ((equal char [f6]) (ww-rename-mode))
	  ((equal char [f7]) (ww-make-directory-mode))
	  ((equal char [f8]) (ww-remove-mode))
	  ((equal char [f9]) (ww-make-symlink-mode))
	  ((or (equal char "\033b") (equal char "\033f")
	       (equal char "\033a") (equal char "\033e")) ;; TODO: What's that??
	       nil)
	  (ww-search-string
	   (ww-process-search char)
	   (ww-redraw))
	  (t
	   (ww-process-command-line char)
	   (ww-draw-command-line t)))
    )
  )

(defun ww-copy-buffer-cancel ()
  "Some character input"
  (interactive)

  (kill-process)
  )

(defun ww-rename-buffer-cancel ()
  "Some character input"
  (interactive)

  (kill-process)
  )

(defun werewolf ()
  "Start Werewolf, file manager for Emacs."
  (interactive)
  
  (ww-init-buffer)

  (ww-refresh t)
  (switch-to-buffer ww-buffer-name)
  (use-local-map ww-mode-map)
  )

;;;;;;;;;;;;;;;;;;;;;
;; Key definitions ;;
;;;;;;;;;;;;;;;;;;;;;
(define-key ww-mode-map "\C-l" 'ww-redraw)
(define-key ww-mode-map "\C-r" 'ww-refresh)

(loop for key in
      (list
       [prior]
       [next]
       [up]
       [down]
       [left]
       [right]
       [enter]
       "\C-p"
       "\C-n"
       "\M-v"
       "\C-v"
       "\C-j"
       "\033\C-j"
       "\C-m"
       "\C-t"
       "\C-o"
       "\M-o"
       "\C-x\C-n" ;; To keep from ^X self-insertion
       "\C-x\C-p" ;; To keep from ^X self-insertion
       "\033<"
       "\033>"
       "\C-s"
       "\C-g"
       "\C-c"
       "\C-f"
       "\C-b"
       "\M-f"
       "\M-b"
       "\C-a"
       "\C-e"
       "\C-k"
       "\C-d"
       "\C-w"
       "\C-u"
       "\C-i"
       ;; "\C-l"
       "\M-p"
       "\M-n"
       "\M-h"
       "\M-i"
       "\M-j"
       "\C-x\C-n"
       "\C-q"
       "\M-m"
       "\M-k"
       "\M-d"
       [?\M-\015]
       "\M-a"
       [f1]
       [f2]
       [f3]
       [f4]
       [f5]
       [f6]
       [f7]
       [f8]
       [t])
      do (define-key ww-mode-map key 'ww-input-char))

;; Copy mode key definitions ;;
(define-key ww-copy-mode-map "\C-c\C-c" 'ww-copy-buffer-cancel)

;; Rename mode key definitions ;;
(define-key ww-rename-mode-map "\C-c\C-c" 'ww-rename-buffer-cancel)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of module ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'werewolf)
