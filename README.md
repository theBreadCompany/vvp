# <img src=https://cdn.discordapp.com/attachments/1034437799048380477/1034442812562878484/VolksverpetzerIcon256x2561xunbordered.png width=7.5% height=7.5%> vvp 


This is the inoffical iOS client for the german anti-fake-news-collective [volksverpetzer](https://www.volksverpetzer.de) (yes it is really against fake-news and does studies and proofs and stuff like that, the translation is like "people's tattletale").

![demo video](https://cdn.discordapp.com/attachments/1034437799048380477/1034455642267713586/sample_dev.mov)

## Disclaimer

This is solely a free-time project of my own, [volksverpetzer](https://volksverpetzer.de) and their respective representatives have nothing to do with it. The only thing they are responsible for is the content of the articles shown.
This, in return, means that I am not responsible for any content, only for _how_ it is presented. 

It simply exists because the founder of the collective suggested to implement an app (as a possible project for them, again, I am simply doing this because I want, not them).
For more information, please have a look at the [LICENSE](https://github.com/theBreadCompany/vvp/blob/main/LICENSE).

Regarding privacy: Regarding privacy: Nothing is uploaded to any servers. Your queries are anonymous, not even views are reported!

## Building and Installing

I will supply IPAs soon. Meanwhile, you have to download and install Xcode, open the projec
- either run directly on your iPhone
- or archive it, open your favorite terminal, type `xcodebuild -exportArchive -archivePath <archive_file.xcarchive> -exportPath ~/Downloads -exportOptionsPlist dist_conf.plist` (dist_conf.plist is in the repo) and sideload it via i.e. Sideloadly

For easier use, I will supply IPAs to sideload directly and/or publish on an inofficial store that does not require jailbraking.

## Targets
- [x] create an app that is able to show lists of articles and the content of them (mostly done; only thing excluded for now is embedded stuff like YouTube videos or twitter posts)
- [x] make stuff readable offline (done)
- [x] archive them (mostly done; one thing missing is displaying locally stored revisions and an image archive)
- [x] share them (done)
- [ ] create them (authed only)(highly optional)
- [x] translate UI to german (done)

Targets marked "(authed only)" are not reachable for now because I need an auth key access the required endpoints. I'll contact the collective as soon as I have something to present.

## TODOs

- [x] open URLs in webviews instead of Safari.app
- [ ] bring style into line with website
- [ ] more unique news entries (with a possible switch to UICollectionView?)
- [ ] declutter
