<a href="https://gitter.im/pl-grading/talk"><img title="Chat on gitter" align="left"
     src="https://badges.gitter.im/pl-grading/talk.svg" /></a>
<img title="Build Status" align="right"
     src="https://github.com/elibarzilay/pl-grading/workflows/Check%20Grading/badge.svg" />

----

# General instructions for grading

Please read this whole text — especially the parts that are marked with
“IMPORTANT”.  If you have ideas on improving it, feel free to do so
freely (commit and I'll see the update and will go over it).

To get access to the git repository, send me your Github username, and
I'll add you.  Grading is done by editing files in the repository, and
pushing the results back out (no PRs needed).

You can use any of the Github tools — they have user-friendly clients
for Windows and OS X, modern editors like VSCode integrate nicely with
GH, and there's even on-line editing tools that you can use.

You can also use plain `git` or any tools that use it — there's really
not that much that you need to know.  If you want to use plain `git`,
then look at the [section in the end](#using-the-git-command-line) that
briefly explains everything that you need to know.

> **IMPORTANT!** In case you have used Github in the past: use these
> tools as much or as little as you want, but do **NOT** do the grading
> using pull requests from your own fork.  In general, avoid making your
> own fork of the grading repository which can end up being publicly
> visible.  (Even if you can create private repository, we're not really
> working on shared code and there are no "reviews", so it's best to
> just commit & merge directly.)
>
> (If you *really* want to share work via PRs, use a branch in the
> grading repository instead of a fork.)


## Process overview and [the grading board]

[the grading board]: ../../projects/1

The complete grading lifecycle goes as follows:
* Students work on their homework and submit, which saves the files
  locally in the handin server.
* When the homework is closed, I sync all files into this repo.
* A github action creates issues for each "batch" of files (batch size
  is configured in `.github/workflows/shared.sh`), with the intention of
  graders grabing a batch to work on it (using [the grading board]).


## Grading

The grading directory will have one directory per homework, and then one
file per submission (ie, for each pair, after the first few
submissions).  Grading files happens in-place — simply edit the files to
add the grading meta-comments, commit the changes, and push.  The files
are anonymized to avoid complaints about grading bias.

There is also an `old` directory with old graded homework, which can be
used as examples of past grading — you can dig there for common
problems, penalties, or whatever.

To grade a file, you edit it and add “meta comments”.  A meta comment is
anything that follows a `;>` (or `;;>` etc).  These comments are used
for all non-student-written meta content (the server rejects student
code that has such comments so this is safe).  You should stick to two
kinds of editing:

* adding a meta-comment line is the most common (usually with a `;;>`
  prefix),

* adding a meta-comment at the end of a line is less common (usually
  with a `;>` prefix) but also useful for quick notes.

(Deciding which one to choose is the same as for comments in general.)

The grading scripts will validate the graded files against the original
submission, and will barf on other edits — the principle is that if you
remove the meta comments, you have *exactly* the student's submission,
unmodified, modulo empty lines (but please don't add lots of empty lines
at the end because DrRacket doesn't allow scrolling up).  BTW, my Emacs
environment highlights these meta-comments, in case you want to try it.

**IMPORTANT!**  The fact that you're grading electronically should help
you in doing so *very* uniformly.  This has lots of advantages:

* It is always good to have uniform grading to avoid (justified) student
  complaints,

* It's much easier to fix mistakes or re-grading decisions if the
  comments are always the same,

* Finally, it's much easier for you (and your editor of choice) to do
  the grading: what I usually do is keep a file with grading comments
  and their penalties, and in case of repeated mistakes I just
  copy-paste the matching line.

The actual contents of the meta-comments is any text at all.  The only
thing with a specific format is the pattern that changes the grade,
which has one of three forms: `<+N>`, `<-N>`, `<*N%>`, `<*M/N>` where N
is some integer.  The first two forms add and subtract from the grade,
the last two are a factor that gets multiplied by the total score
(regardless of the order in the file).

For the homework, the server adds a meta-comment line with a `<+100>`,
so the grading is done by writing negative `<-N>` penalties.  `<*N%>` is
for rare cases where some global penalty is needed (late submissions,
cheaters, etc).  The grade is computed using just these three forms: the
sum of positive and negative patterns, multiplied by all factors, if
any.  No other magic.  (See also the `get-score` below.)

Again, since there are lots of common mistakes, it is a good idea to
have an open buffer somewhere with meta-comments regarding common
mistakes with their penalty, and then cut & paste to grade additional
works (adding new common lines to this buffer).

For each homework you should also get a `solution.rkt` file and a
`tests.rktl` file in the directory; the first is to see how a good
solution looks like, and the second is to test submissions.  You can
revise these files as you see fit, improving the solution (or maybe
writing alternative solutions), and add more tests that catch student
mistakes.  (The first homework is an exception: there are no tests for
it since the server is allowing only submissions that pass its own
tests.)

### Grading the intro homework (1, 2, and 3)

**IMPORTANT!**  It is a good idea to lean towards harsher penalties in
the intro homework.  The weights of these homework is relatively small
compared to the rest (specifically, HW#1 usually ends up being less than
1% of the grade, HW#2 a bit more than that, and HW#3 yet more).  This
makes it possible to have harsh-looking penalities that ensure that
students will notice them and improve their future code, while not
having a big overall damage to their grade.  So take this chance to
point at all mistakes that they do, improving their future code and
making your future gradings easier.

### Regrading and other fixes

To make it possible to deal with problems and complaints, you should
*always* add a `;;> Graded by ___` line (just below the `<+100>` line).
Since the grading files are anonymized, it will not be easy to find the
file for a specific student.  The anonymization process adds an
identifying line to the files that students get back:

    Grading File: hw01/23.rkt

This has the grading directory and file name which you worked on, so ask
the student to give you that line to find their submission in the
grading repository.


## Scripts

There are a few scripts here that can help you.  Each one is a standard
script that can tell you how to use it with a `-h` flag.  See the
comments in the scripts for more information.

#### `check-style`: finds common style problems in code

This script is useful when you start working on a homework, especially
in the first few, where style is very important.  It has a `-p` flag to
make it output annotated files (with meta-comments indicating style
errors), which you can use as a starting point.  But note that you
should never take these comments in blindly, without reading through
them — the script is inherently approximate and will often have bogus
mistakes pointed out, or miss some other mistakes.  Also, it does not
write any score penalties, so you need to do that (if you want to use
its output).

  > **IMPORTANT!**  Do **not** use this tool blindly!  Note that I
  > sometimes diverge from these rules (I have good reasons to do so),
  > and you shouldn't penalize students for code that they've seen in
  > class, or worse — code that they were given.  For example, I ask
  > them that each parenthesized form should be all on one line, or if
  > it's too long then newlines should be used between all arguments.
  > But I often sometimes do something like this:
  >
  >     (error 'blah "some error message, ~s"
  >            some arguments)
  >
  > since in this case the symbol and string are kind of like one part;
  > and sometimes I write code like
  >
  >     (cases x
  >       [(Foo x y) (f blah
  >                     blah)])
  >
  > because I prefer to have the patterns more visible even when the
  > result expression takes a few lines.  Please pay attention to this:
  > there have been embarrassing cases where students got penalized for
  > style issues in lines that they got with the homework!

  In any case, the style grading should be very picky on the first one
  or two submissions, then the level of pickyness should go down.  The
  penalty amounts for style should also go down in time.  There are a
  few things like “misleading indentation” that should be considered
  bugs all the way throughout the course (and these should have much
  higher penalties than regular “style issues” accordingly).

#### `test-files`: run the test suite on a file (or a bunch of files)

Almost all homework come with a `tests.rktl` file, this script can be
used to run these tests and report failures in the file.  (The tests are
usually taken from the solutions, and sometimes extended a bit.)  Doing
this can be very effective in finding out common problems — so please
use it, and if you see some bug that it doesn't catch, then *please* add
a test for it (so you can use it with other homework, including ones you
already graded that might have slipped through).  Please commit such
additions (and/or corrections to the solution), I'll be notified of the
change so I'll know update the originals.

> **IMPORTANT!**  Do *not* fall into the trap of penalizing submissions
> based on just test failures!  Such failures are symptoms of bugs in
> the code, and you should take points off for the **actual** bugs, not
> for their symptoms.  It can easily be unfair to students who did
> something different (eg, changed error messages), or some relatively
> tiny bug might lead to lots of test failures and a per-test penalty
> will be very unfair.  If you add tests (or with existing ones) you can
> also add comments next to them that explain what the corresponding
> failure might be, for future graders use.  Note also that some things
> are not covered by tests or by style — like the classic mistake that
> some people do with list accumulation:
>
>     (loop x y z (append acc (list new-item)))
>
> Finally, if you grade the bug rather than the N-failing-tests
> indication, you can judge better the kind of penalty.

#### `get-score`: compute the score of submissions

This is a quick script to check the score of submission file/s, even
whole directories.  When used with multiple files (or a whole
directory), it will tell you things like the average and standard
deviation.

#### `check-gradings`: sanity checks for graded files

Run this script to ensure that your commented files did not change any
of the original contents.  Run this from a directory you want to check,
or give it a directory name as an argument.  It's also set up as a
github action that runs on all updates, and you would be notified when
you push files that have an issue in them.


## Miscellaneous

Urgent deadlines are rare.  There are a few times when I'll need grades
fast, but it's mostly just keeping up with the submissions, and trying
not to get the students too angry...  The times when I'll need grades
fast are usually these:

* The last individual homework (usually #2) — I need the grades to
  assign people who do not have pairs (so only unpaired people are
  urgent).

* The last homework before the last drop date — I need grades to talk to
  students that should really consider whether they want to go all the
  way to the end (so only grades for weak students are urgent).

* The end of the semester is very urgent, of course.  (It usually creeps
  up and surprises everyone by how fast it comes.)

* Finally, I'll let you know if students are about to go on a hunger
  strike, but you'll probably see that in emails and on piazza.

**IMPORTANT!**  In any case, try not to lag too much.  Eventually,
students will complain very loudly...  But more importantly: the main
goal of grading is for the students to get useful feedback; a lag makes
that feedback much less useful.  This also leads to some of the above
points, for example, a “failed three tests” grading comment providing no
useful feedback.  So the main aspect of your job is essentially
providing good feedback.

For each homework, you should go over the text and see if you have any
questions.  (It's actually a good idea to go over it when I put it out,
in case you spot any typos or other problems.)  I usually like to leave
the grade distribution to you — almost anything is fine with me as long
as it's sensible (roughly distributed according to the workload) and
consistent; so feel free to send me what you think the score
distribution should be, or to ask me how it should be divided.

Again, the stress for what should be graded is all stuff that you should
be familiar with.  Penalties for almost anything you can think of:

* Code that is buggy, confusing, over complicated, partial, inefficient,
  or over-optimized.  Bugs are of course the worst, the next level up is
  code that is repeated instead of using functions.

* Code that doesn't look good is included too: weird spacing (both
  spaces and newlines) of all kinds, and bad indentation.  There's
  obviously a range here too, from a very light penalty for some extra
  spaces, higher penalty to a space/newline before a closing paren or
  after an open paren, higher for badly indented code, even higher for
  no indentation (flat code), and bug-level for “out-dents”.  See the
  lecture notes for some horrible (somewhere around lecture #2 or #3).
  Note that missing indentation is extremely bad, since that make the
  code not look like its structure; for example:

      (if foo
          (+ bar 1)
      (baz 2))

  Such things should always be penalized as if they're bugs, even at the
  end of the course...  You might also to see the frantic-submitter
  syndrome: people who waited to the last second, then panicked when the
  server rejected long lines so they just hit enter in random places...
  There's also the kind that does that while still respecting DrRacket:

      (define (foo expr)
        (cases expr
          [(Fun ...blah blah...) (+ (eval ...blah...) (foo
                                                       (bar (baz)))
                                    3)]
          ...))

  and if you're lucky you might get a sighting of these guys:

      (define (foo expr)
        (cases expr
          [(Fun ...blah blah blah...) (+ (eval ...blah...) (foo
      (bar (baz))) 3)]
          ...))

* Also very important are the function headers (contract lines more than
  purpose statements (which is usually copied from the HW text)), and
  tests.  I almost always make complete coverage a requirement, but it
  is still possible to write some brain-dead useless tests (like testing
  sets that are represented by lists with a plain `equal?`, instead of
  using set equality).

* Other stylistic issues to consider are name choices (too short, too
  verbose, confused, or conventionsFromOtherLanguages); paren shapes
  (use square brackets where we usually do, never use curly braces in
  Racket), etc.  Note that using curly braces is very unidiomatic in
  Racket code, and in the class it pretty much always an indication of a
  student who confuses Racket code from code in the implemented
  language(s).

* You should also keep an eye for cheaters, but not too hard.  When they
  come, it's usually so obvious that it slaps you in the face.

And remember, all of this should be adjusted, from HW#1 where style etc
is the *only* thing, and later on it becomes less important when there's
real meat to deal with.  Hopefully, by then the students have been
slapped enough that they will produce better code, which in your case
has the advantage of being easier to grade.  Because of the good effect
of penalizing bad style, you shouldn't be afraid to do so harshly in the
early stages.  The damage to students is minimized by the small weight
of these submissions, but the contribution to making them write clear
code later on will make your work *much* easier.


## Using the `git` command-line

To get the grading repository, use:

    cd <where you want the grading directory to be>
    git clone git@github.com:elibarzilay/pl-grading.git <grading-dir>
    # or: git clone https://github.com/elibarzilay/pl-grading.git ...

where `<grading-dir>` is whatever directory you want to call it.
Remember to close it for reading — good in general, but especially if
you have this in your department account:

    chmod 700 <grading-dir>

To update the grading directory, (eg, when a new homework is pushed):

    cd <grading-dir>
    git pull --rebase

The reason for the `--rebase` flag is related to how git works, if you
want to know more about git, there's a ton of stuff on the web.  For the
purpose of grading work, you'll do much more basic stuff anyway, so no
reading is needed.

Once you've graded a homework — or if you changed any grading on some
older file, you need to first commit your changes:

    git commit -a

(The `-a` flag tells it to commit all modifications to the repository.
If you want to work with git for real code, beware that it's not a good
habit.)

Git will fire up your editor (which you can configure using the
`$EDITOR` environment variable) so you can write a commit message —
please write something indicative, since I'll be reading those commit
messages.  For example use “graded hw10”, or write a message about a
grading change — which can be long and include emails or whatever you
want to put there.  If the message is a short one-line thing, you can do
it on the command line with a `-m` flag, for example:

    git commit -a -m "Graded homework 6"

Either way, git commits happen locally in your own repository — nothing
is updated on the server.  You can therefore do any number of commits
that you want.

Once you have the commit (or commits) that you want, you need to “push”
them to the server:

    git push

Note that this will barf if the repository on the server has been
updated — in this case you'll need to run `git pull --rebase` again, and
then push.

The barf may look something like:

    To git@git.racket-lang.org:eli/pl-grading
     ! [rejected]        master -> master (non-fast-forward)
    error: failed to push some refs to 'git@github.com:elibarzilay/
    pl-grading'
    hint: Updates were rejected because the tip of your current branch
    hint: is behind its remote counterpart. Integrate the remote changes
    hint: (e.g. 'git pull ...') before pushing again.
    hint: See the 'Note about fast-forwards' in 'git push --help' for
    hint: details.
    git exited abnormally with code 1.

(The short version is that git is telling you that you're trying to push
a different history, since your history isn't based on the new commit
that was pushed.  Doing a `git pull --rebase` will update your repo,
then “replay” your commit(s) on top of that new history, so it can now
be pushed.)
