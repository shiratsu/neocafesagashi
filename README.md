# NeoCafesagashi

I developed it in 2014.
I try to re-develop by swift lately.but i will decide not to re-develop.
Because i want to understand ob-c more.

## Some Point
DB process is Async but View process is not Async
http://omokichi.sakura.ne.jp/blog/coredata%E3%81%8C%E3%83%80%E3%83%A1%E3%81%AA%E3%82%89fmdb%E3%82%92%E4%BD%BF%E3%81%88%E3%81%B0%E3%81%84%E3%81%84%E3%81%98%E3%82%83%E3%81%AA%E3%81%84/
http://blog.77jp.net/dispatch_async-copy-paste

## DB
this aprication use DMDB.because FMDB can use sqlite easier than CoreData.

## From iOS8
LocationManager need to listen whether to use location sencer.
http://qiita.com/monkick@github/items/50bd13a7e60e18e96d3a

## about 循環参照
http://south37.hatenablog.com/entry/2014/07/06/Objctive-C%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8Bweak%E5%8F%82%E7%85%A7%E3%81%AE%E4%BD%BF%E3%81%84%E3%81%A9%E3%81%93%E3%82%8D%E3%81%A3%E3%81%A6%E5%88%86%E3%81%8B%E3%82%8A%E3%81%A5%E3%82%89%E3%81%84

## after understanding 循環参照
i realized 循環参照 position on ViewController.of course i fixed.

## i replaced fmdb which is gotten from cocoapods.
this occured several problems.but i resolved it.
http://ja.stackoverflow.com/questions/7043/pods%E3%81%AE%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%81%A7%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%AB%E3%82%A8%E3%83%A9%E3%83%BC/7048#7048

when nsmutablearray has exc_bad_access

maybe i will fix.

http://stackoverflow.com/questions/3967104/nsmutablearray-exc-bad-access-when-i-try-read-from-it

https://github.com/shiratsu/neocafesagashi/commit/8068e7846e2d3e3ef71401c63d77a588a7165564
