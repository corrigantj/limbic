Impromptu Google Meet Meeting - February 20
VIEW RECORDING - 99 mins (No highlights): https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec

---

0:24 - Travis Corrigan (matterflowadvisors.com)
  Okay, so the two things to note here. One is, we have this doc for CloudPM, which is actually a rev that is ignorant of what I currently have for CloudPM.  And CloudPM addresses most of the, like, structure, which is have a PRD. And. And. Verted into Milestone with Issues, then dispatch a bunch of parallel LLM, parallel agents, each in its own work tree to implement with TDD and PRs.  PM Status is a live dashboard from GitHub State, so it just works across session crashes. And then PM Integrate, which is the PR stuff.  It uses superpowers for a lot of these mechanics. So the brainstorming, the TDD, the work trees, the debugging, all of that comes out of superpowers.  Yeah, that makes sense. So when you and I finalize this Google Doc here, I'm going to update the markdown, and then I'm going to hand this along with this transcript to CloudCode in a brainstorming session to go, okay, great.  We're going to update. This repo to include these new things. So that's sort of the, like, just a little bit of a bigger picture context of where we are in terms of, or where I've been thinking in terms of bringing these ideas together.  So that's great.

2:16 - Derek Perez
  Yeah.

2:17 - Travis Corrigan (matterflowadvisors.com)
  So yeah, the Google Doc itself doesn't have the PR stuff that absolutely should. I, this is a part of engineering management.  I've not done myself directly. So although I did have Claude give me a primer on how to do it.  Yeah.

2:37 - Derek Perez
  I think we'll, we'll discuss that in depth. I think. Yeah.

2:40 - Travis Corrigan (matterflowadvisors.com)
  I'm like, I'm an, I'm an, I'm a new engineering manager with only AI agent employees, like developer employees. What new advice do you have for me?  And it gave me some good .

2:52 - Derek Perez
  Okay.

2:54 - Travis Corrigan (matterflowadvisors.com)
  So, okay. I've gone through most of the comments, but not.

2:59 - Derek Perez
  So let's There's like repo level things you can install to validate that. Okay. And I think as a Claude plugin, could go even a step forward and say, we can do a tool commit, like a tool hook that if we see it do a get message, that it can check it there before it even touches that.  So we can attach conventional commit validation as a requirement a couple different ways and decide which one's the most ergonomic.  Okay. But overall, it sounds like we're going to probably get into PR stuff. So let's just keep moving a little bit through this.  Another insight that I'd want brainstorming to take a look at is what opportunities we have to provide guardrails and feedback to the system that's defined here through GitHub Actions as well.  So when you install the plugin, the plugin is going to go into the repo and the project kind of synonymously.  And so it can... Add actions that would then run remotely. And those could be used to introduce any kind of like linters, which I'm using as a general term for like, you know, acceptance rules about how these things should look, right?  So if we're talking about, you know, there's certain things, fields, structure that you want to see in PRDs or issues or tasks, we would use GitHub's actions.  And we could trigger them to check those workflows whenever they're submitted. Now, when we do that, though, we also need Cloud Code to basically say like, okay, I fired that off.  And now I need to go review what outstanding actions that triggered and make sure that all of them are done and that I've reviewed any outstanding lint failures and looped back to fix any of them if I introduce them.  Okay. Right. So that would make it so that, like, let's say. It commits a change to a story, but it forgot to add a particular field in a story.  We would want it to say, great, here I've created the issue. I'm going to wait for actions to run.  I'm going to check the resolution of actions. Did anything go wrong? If so, address those issues and do that again in a loop until I get a clean lint check from the action I took.  And then I'm allowed to move on. Right, this will make it so that if we have any variance in model instruction following, that at least GitHub actions will gate and lint checks will gate so it doesn't keep moving forward and causing distortion or noise in any artifacts it's producing.  Okay.

6:47 - Travis Corrigan (matterflowadvisors.com)
  So using GitHub actions to deterministically script certain things at different... Different points in the development life cycle, including and especially project setup inside of a new repo.

7:09 - Derek Perez
  Yeah, or any kind of thing that it could get wrong where it has free form control, like the templates, right?  Like is every field you expect to see in the template there, right? Like those sorts of things we can adjust and control and we can have little scripts that are just literally like looking for those terms in the outputs.  Yeah.

7:29 - Travis Corrigan (matterflowadvisors.com)
  Right.

7:30 - Derek Perez
  And that'll just make sure that we don't miss anything and that the system doesn't progress until it's in a resolved clean state.  Yep.

7:43 - Travis Corrigan (matterflowadvisors.com)
  There's CCPM actually has a decent amount of this already with its shell scripts. Yeah. And some hooks.

7:54 - Derek Perez
  Yeah, it didn't use, it didn't use actions and like actions, the downside to actions is that. They're a little slow and they're asynchronous and so they won't block.  So maybe it's too prescriptive to say we should use actions for this and it will slow things down and we could just like look at that before it exits and is submitted.  Yeah. So I guess I would say either solution is fine, but the problem needs to be addressed in the specification, I think, is all I'm really pointing to.  Got it. It's like we need like a lint process to make sure things that pushes meet our expectations consistently.  Okay, got that.

8:39 - Travis Corrigan (matterflowadvisors.com)
  And so during the brainstorming, Cloud Code needs to ask us about what are the things that we want to be doing in terms of linting and then figuring out the helping us map that problem space and then recommending to us some potential solution.  Um, to us based on certain preferences that we have, like, do we want it to run asynchronous or not?  Do we want it to be blocking or not? Stuff like that.

9:10 - Derek Perez
  Yeah. I think no matter what, you probably want it to be blocking because you don't want to end up in a world where information's missing and you don't notice it till later.  Yeah. Right. So I think it should block. It probably should be synchronous because it's going to be ultimately faster.  And I think it could happen client side.

9:28 - Travis Corrigan (matterflowadvisors.com)
  Okay.

9:29 - Derek Perez
  So, like, because it's basically, like, what's the markdown I'm sending to this thing? You can check that locally, I guess.  So we may not need GitHub actions for this, actually, the more I think about it. Okay.

9:39 - Travis Corrigan (matterflowadvisors.com)
  Um, okay. Can we move on?

9:42 - Derek Perez
  Yeah. Okay.

9:46 - Travis Corrigan (matterflowadvisors.com)
  The naming conventions for PRDs and epics. Uh, the next one I see is about...

9:55 - Derek Perez
  A label taxonomy. Yeah, label taxonomy. Yeah. Um, I was... This was just a call out for like, it might be nice to create a meta namespace, like a meta colon style namespace along with all the other ones.  Okay. Specifically so that we can introduce any kind of control or overloads or overrides that we can't necessarily predict.  So for example, let's say there's an issue or some artifact that could be pulled into context for a clod.  Um, we would want to say like, restrict this one or like redact this one. This one's not part. Don't use this one.  Got it. And I don't really know when we'd do that, but it's possible that like something goes way off the rails and we just, it's in the history, it's in the historical record, but we want it to be redacted.  Got it.

10:53 - Travis Corrigan (matterflowadvisors.com)
  Um, so why don't we call those agent labels? those agent that's... need this If you

11:01 - Derek Perez
  Fine.

11:02 - Travis Corrigan (matterflowadvisors.com)
  Is it, are they specific for LLMs or like, is this a thing, is this a label that we really want the LLMs to attend to like strongly?

11:14 - Derek Perez
  It's more in my mind, like something we would say, like when you're doing a query for like issues, you would remove any that have this tag, for example.  Right. So it's, it's like not really, I mean, it's ultimately for them, but the job to be done is sort of vague.  I just want to create like a vagueness zone so that we could use that as needed. So we have that as like an escape hatch pattern.  Yeah. Like, like meta ignore is nice because that would just be like, if you ever see this tag on anything, don't pull it into context.  Yeah.

11:52 - Travis Corrigan (matterflowadvisors.com)
  Yeah.

11:56 - Derek Perez
  That's the only practical one I can think of right now. Thank Thank Thank Thank

13:00 - Travis Corrigan (matterflowadvisors.com)
  Cool. Yeah, I'm not sure why I gave this instead of issue types. I want to use issue types. Issue types.

13:08 - Derek Perez
  Now, can you demonstrate to me what the difference is? Because I wasn't even really sure what an issue type is.

13:16 - Travis Corrigan (matterflowadvisors.com)
  I think an issue type is... It's right here. It's a... Okay, okay, okay.

13:33 - Derek Perez
  So it's not a label. And these are labels.

13:36 - Travis Corrigan (matterflowadvisors.com)
  Okay.

13:39 - Derek Perez
  Okay, that seems fine to me. Yeah, so then we'll just pull that out as a specific... Instead of using type labels, we'll use types for issues.  Yeah.

13:52 - Travis Corrigan (matterflowadvisors.com)
  I see. Okay.

13:53 - Derek Perez
  That makes sense. Um, like, as task types though?

14:07 - Travis Corrigan (matterflowadvisors.com)
  Story, task, bug, retro, spike? Yeah, I think that seems fine to me.

14:14 - Derek Perez
  One that I don't know if it's worth calling out, like, as a, as a pattern I've noticed in conventional commits, they have this premise of chore.  Um, now, arguably, what's the difference between a task and a chore? I don't know.

14:33 - Travis Corrigan (matterflowadvisors.com)
  I think it's in the conventional commits, honestly. It is. It's one of the called ones.

14:39 - Derek Perez
  Um, they have, like, fix, feat, build, chore, CI, docs, style, refactor, perf, test. But, like, honestly, so many of those could fall under task that I don't know that we need the granularity outside of the commit.  So, like, maybe that's fine. I task could, you know, potentially be one of those. Yeah.

15:08 - Travis Corrigan (matterflowadvisors.com)
  Yeah. Yeah, I think that's right. Dev tasks are...

15:15 - Derek Perez
  Kind of miscellaneous tasks, right? Right.
  ACTION ITEM: Update Claude PM spec: remove retro issue type; add Lessons step; add Wiki homepage link - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=920.9999

15:20 - Travis Corrigan (matterflowadvisors.com)
  Task is generic and have to, I think, hold both, like, actual feature development work as well as chores. So, I might...

15:31 - Derek Perez
  So, two things I was thinking about, I didn't notice this at the time, I'm going to advocate to drop retrospect as a type because I want to move retrospectives to the wiki.

15:42 - Travis Corrigan (matterflowadvisors.com)
  Okay.

15:43 - Derek Perez
  And then, similarly, just for language simplicity, I would change type spike to type research if you're going to use that for research.  Okay.

15:55 - Travis Corrigan (matterflowadvisors.com)
  Do we want a task to be a retro task type that... It gets stored as a way to measure the unit of work of completing a retro.  I agree with you that the retro artifacts themselves should live in wikis.

16:13 - Derek Perez
  Yeah, I would just call it a task. Okay. Because if we're going to say, like, kind of, that simplifies the language to this is a story, this is a bug, this is a task.  Yeah, okay. And I think if there is a reason, and this is research, right? I don't think there's much value in a lot of granularity there.  And I think those are, we can think of these as, like, the four pathways that you need to be thinking through.  It's like, if it's not a story or a bug or research, I mean, arguably, you could say, why isn't research a task?  But I think it's reasonable to argue that it's not.

16:55 - Travis Corrigan (matterflowadvisors.com)
  I think, so the reason why we had, well, this is what's interesting is that. you. you. The reason why I had to create research tasks was that I actually had to, in sprint planning, carve out capacity, sprint capacity for a human to do technical research, to de-risk as an input to technical design for some product decisions that we needed to make.  That way we had a more informed set of, you we the product team could use that research and those recommendations from engineering to then go, okay, cool, here's what we should do instead.  Rather than us be prescriptive in a vacuum, it's actually go, here's what we're thinking, go take a look or explain to us how this currently works, and given the sort of desired objectives of what we could build, what would be possible solutions?  So, actually, technically, this is all solved by the brainstorming, like, step. Yeah, but, but you might tell the agent to run the brainstorming step, so.

18:02 - Derek Perez
  I mean, in a world of full autonomy, telling the agent to do research and come back to the issue with what it found is kind of a plausible thing.

18:13 - Travis Corrigan (matterflowadvisors.com)
  Yeah, if we want the research to be separate from the plan, it builds. Oh, that's true. And I think that...

18:49 - Derek Perez
  Maybe we just drop it then. Yeah, I think we can drop it. So then we'll just keep it focused to story task bug.  So I'm looking at the...

18:58 - Travis Corrigan (matterflowadvisors.com)
  at I'm looking I'm looking I'm I'm Yeah.

19:08 - Derek Perez
  Yeah, if you think that research has happened, if research isn't really allowed to happen in the bounds of an epic, then...

19:14 - Travis Corrigan (matterflowadvisors.com)
  Yeah, I think it is within the bounds of an epic, but I don't think it needs to be tracked as its own ticket.  It's online, okay. Because the output of that thing is going... So the output of research is really going to be like an hour, right?  Yeah. And then on the long side. Yeah. And what I typically asked dev teams in the past to do, this is basically this.  Like... Yeah.

19:45 - Derek Perez
  Present a design and then write a design doc.

19:47 - Travis Corrigan (matterflowadvisors.com)
  And then it saves the design doc to a particular place and then commits. So... No, let's drop it then.  And then it transitions to implementation plan. Right. Which is like technical .

20:02 - Derek Perez
  Yeah, we've inverted this a little bit. So why don't we drop it for now and just say like, if these three don't fit, we can always augment it.  But I think you're right that this is kind of the right organization. Yeah. Next thing I was working through was sizes and sizes having any, like the one thing I ran into pretty early and I saw Claude pretending to play this game with me was trying to designate what it thinks is a temporal boundary on a task, like sizing.  Yeah. like, oh, this should take, this sprint should take three weeks. And it was like, what? Like, maybe, but you're going to do this in like one minute.  And so size could be interesting just in terms of like distribution of tasks. Sure. We're looking, but we might want to look at.  Yeah. A different measurement system, like points, and just let it have point weights, and then decide, like, these are the intervals.  And if it's this many points, it's this size.

21:11 - Travis Corrigan (matterflowadvisors.com)
  I actually think that points is smart. And I think we are no longer speaking about time anymore. We're speaking about how many tokens is this task going to take.  Right. So we are now measuring tokens. Oh, interesting.

21:30 - Derek Perez
  Right.

21:32 - Travis Corrigan (matterflowadvisors.com)
  I'm not going ask for a token approximation. Why not? I mean, frankly, that would be really rad, is, like, estimate, because this is part of Agile, right?  It's like, we estimate points, and then we, like, see how long it actually took. So it's just, like, estimate the tokens, and then let's look at the actual tokens spent.  I think I love, I love that.

21:55 - Derek Perez
  Let's, let's orient size towards token estimates. Okay. And what I wonder if we can do then is in retros and commits, now that'll be very interesting because the question will be, how will it know and calibrate?  Yeah. And I don't know, but I think we should try to figure that out or ask it to figure that out.

22:17 - Travis Corrigan (matterflowadvisors.com)
  I think this is like a telemetry thing where we would have to do something that I don't know, I'm not even sure if  Claude allows us to do that.

22:31 - Derek Perez
  Oh yeah, they do. I mean, it's there, it's knowable. Okay, right. So what we'd have to say is that at the end of completing a task, you would need to try to estimate the actual tokens it took to do that.  And that's not a measurement of the diff. That's a measurement of the conversation in the session. Yeah, right. But I'm pretty sure it's knowable because like we have it in the status line, we have all that , right?  Yeah. Yeah. So I believe it's doable, and I don't think we need to care about how.

23:03 - Travis Corrigan (matterflowadvisors.com)
  I think it's doable, and I don't think we need to care too much about hyper-precision accuracy. No, even just loose ballparks.

23:14 - Derek Perez
  I'm not bean counting this, but maybe even possible if it goes and runs TickToken or whatever the  on the Markdown files or JSON-L files that it has.  Yeah, right. Right, like there's many approaches that would be rough estimates that are interesting, because what I would hope is, thinking about the whole arc, when it gets to the retrospective and it does token estimate comparison, it can then look at what it thought it was, and then it can calibrate over time.  That's kind of what you want to see, and that's like how the point system worked, right? So if we're switching to token counts instead of points, we actually have a measurable metric that even humans don't have.  That's right, which is extremely interesting. So let's keep on that thread. I like that. What we want? Interval buckets, then the next run, it would do that.  Yeah.

25:05 - Travis Corrigan (matterflowadvisors.com)
  Okay. Cool.

25:07 - Derek Perez
  Yeah. Yeah. I like that a lot. Okay. Moving down to, I'm now at layer three for wiki. So one thing I was just seeing here was I've had pretty good experience with having PRDs have an acceptance criteria, which is mostly a free form list of like things you could check off and say like, it does this, it does this, it does this.  I wasn't sure if that's what you felt like objectives were already supporting. The objectives are.

25:43 - Travis Corrigan (matterflowadvisors.com)
  Or metrics.

25:44 - Derek Perez
  I wasn't totally sure how you were thinking about it. So I just wanted to raise it as a point of discussion.  Yeah.

25:48 - Travis Corrigan (matterflowadvisors.com)
  The objectives are like. Sort of like. OKRs a little bit. Let there was a, let's see where it, it probably got this from one of my previous product briefs.  So let's just look at what I thought I should do. Okay. And then we can determine what we want.

26:19 - Derek Perez
  Okay.

26:21 - Travis Corrigan (matterflowadvisors.com)
  Okay. So these were pretty high, pretty broad.

26:30 - Derek Perez
  Yeah.

26:30 - Travis Corrigan (matterflowadvisors.com)
  And they're mostly designed to provide grounding focus for a very ADHD scattered engineering and founder team. Okay.

26:51 - Derek Perez
  Which may not be relevant for us.

26:53 - Travis Corrigan (matterflowadvisors.com)
  So, yeah.

26:55 - Derek Perez
  So thinking about it in that lens, if I were to pull up. Kind of the two extremes. And so I don't know if it needs to be like that.

28:06 - Travis Corrigan (matterflowadvisors.com)
  I think that at a PRD level, I typically am a bit more generic about what the success criteria is.  So I'd say like app meets all functional requirements as described in these product tickets. It's the app front end matches the designs as described, like as enumerated here.  And usually I linked to like a Figma file, right? So there's a little bit of that. Analytics tags are instrumented and are feeding into our, you know, business intelligence.  And we have like a dashboard or updates to an existing dashboard or report. For that thing. Okay. There are no P, you know, there are no P1.  They're, you know, they're, but P2 and P3 bugs are okay. So those are examples in which I've sort of been generic about that stuff.  Because at the, at the, because then I recursively do acceptance criteria at the product ticket level. And that's where I get into the Gherkins stuff.

29:17 - Derek Perez
  Well, that, that's what I was assuming is the success criteria here would dictate what the shape of those would be as issues.  Yeah. Right. Right. It's like kind of a directive to be like, this is what I'm telling you to figure out how to map into your, your organizational system.  And I do think you're right. There are probably some like generic preambles, like all bugs must be addressed. Yeah.  Or resolved by some way. Right. Right. So I think that's, I think that's probably right that it would be here because that would be sort of like, this is the point of definition where that distribution would occur.  Yeah. Which is otherwise not defined. Right. So I would. That the system selects from, right? Because there could be a world where a scope matrix makes sense, right?  But there could also be like completely different things based on the project. And it may be hard to predict.  So either we could have templates that the project's allowed to control and own that live in the project, or we are non-prescriptive and we just see what brainstorming does.

31:28 - Travis Corrigan (matterflowadvisors.com)
  I want to try and be non-prescriptive, which is a model violation for you, I'm sure. No, no, no, I'm with you on this.  Because I'm trying brainstorming and I'm like, okay, like, let me see what I like here. And let me see whether or not this produces an artifact that decomposes into epics and product tickets and stuff like that.  I still haven't done that yet. So I don't want to be prescriptive yet about what. What PRDs look like, or what the brainstorming output is.  Totally happy with that.

32:07 - Derek Perez
  And I think that melds well with the recent research findings we were talking about, about reduced context, like not overfitting context, and the whole like, you know, are LLMs allowed to do their job better because they have more autonomy in that way and they're not overly instructed?  Yeah. So I'm happy to do that. Yeah. So then in that way, then it's probably good to look through all the templates to make them less descriptive by default.  And then we can refine them and tighten them if we find that they're going off the rails as a general guidance for the next iteration.  Um, the next one that caught my attention was, um, flows and designs and stuff. And like, I think that one of the things that's sort of challenging here is we can attach pretty much only images to wiki.  Yeah. Which maybe that constraint is good because that. That's also kind of all we can give Claude. That's not like text, right?  Like, I don't know if you've ever tried this, but you can actually drag an image into Claude code. Oh, I've done that.

33:12 - Travis Corrigan (matterflowadvisors.com)
  Yeah, it's bad. There is something around MCP. I have actually a mermaid MCP in here. Oh, cool.

33:24 - Derek Perez
  So you can get...

33:26 - Travis Corrigan (matterflowadvisors.com)
  But you could have just put that in the markdown.

33:29 - Derek Perez
  Right.

33:30 - Travis Corrigan (matterflowadvisors.com)
  You know what mean? What I'm worried more about is like comps or prototype.

33:35 - Derek Perez
  Like the things that are getting called out here are going to be hard to share unless we point to specific MCPs.  Like I think there's a Figma MCP if we were to use that. Yeah. You know what I mean? So like I don't really think this is something to over worry about, but it caught my attention when I was evaluating the capabilities of Wiki.  And it was like you can... Attach images, and that's it. So it's like whatever's in the main, and the other thing is, unless you want to do, if you want to do appendices, it's going to be either in this file or subfile.  Yeah.

34:12 - Travis Corrigan (matterflowadvisors.com)
  And it has to be text or images, which isn't bad.

34:16 - Derek Perez
  Yeah. Okay.

34:18 - Travis Corrigan (matterflowadvisors.com)
  So, I mean, honestly, we can leave this out for this version. So, I have CloudPM v1, right? You and I are talking through CloudPM v2 right now?  Yes. But for v2, we can just drop this, because majority of our development is going to be non-frontend. Yeah.  And I don't know how you think about designing a flow diagram for an agentic thing that is sort of semi-deterministically executed.  You know what mean? Yeah.

34:51 - Derek Perez
  I mean, I would probably defer to what it wants to do, graphism, mermaid, whatever. You know what I mean?  This is, again, I think a reduction of prescription. Yeah. Yeah. I think... think...

35:00 - Travis Corrigan (matterflowadvisors.com)
  To the extent that if there is anything here, it would be a digraph that the agent decides to put here.  That's what I mean.

35:14 - Derek Perez
  Do you want to keep this section?

35:15 - Travis Corrigan (matterflowadvisors.com)
  Because even then, that's still overly prescriptive. But maybe we want that. I don't know.

35:21 - Derek Perez
  I think that this might be an example of like, we just tell it to include necessary flow definitions if they're required to clarify something.  Okay. You know, so like, it doesn't need, we don't need to have these things necessarily. Similarly with like analytics requirements, that feels like, again, sort of overfit.  Yep. But, but I, I see where this is coming from, but I think, I think we both agree that the best path forward is to just be less prescriptive about requirements, but probably there are some we always want to hit.  And that's. Google has a code owner's file system in Google 3 because every project is in one repo. And so this allows you to define, essentially, if you touch any file that ends in JS, this person owns it.  Wow. Right? And so what that'll do is when PRs kick off, it'll auto add those people to them. Got it.  Okay. And then they need approvals from those groups. And I think you can even set up, like, groups and stuff, global owners, profiles, folders, like, regexes.  You can do a lot of stuff. Okay. But what's interesting is I think we could use this to designate, like, these are the names that she would use to, like, address an open question about this part of the code.  Yeah. Okay. Or something like that. Or, like, how, you know, how, what I was pointing out was how does the system know who owns what?

38:54 - Travis Corrigan (matterflowadvisors.com)
  Right. Right.

38:55 - Derek Perez
  And so we need a system to rely on, and this one's just there. So. We could just use this.  Okay.

39:03 - Travis Corrigan (matterflowadvisors.com)
  How do we want to think about the owners that we have?

39:10 - Derek Perez
  I think it doesn't matter to us, right? So like if we just say like consult code owners whenever you need to assign an owner to a question or a risk, right?  Like I think we don't need to think too hard about it. But it just needs like a point of reference to know who, like how does it decide who owns something?  Yeah.

39:33 - Travis Corrigan (matterflowadvisors.com)
  I mean, are the owners all going to be human or are they going to, are there going be robots with them?  Because if they're going to be robots, we have a memory context window session problem.

39:46 - Derek Perez
  I think that's up to us, but we could also assign robots to GitHub identities. Yeah.

39:53 - Travis Corrigan (matterflowadvisors.com)
  Theoretically.

39:53 - Derek Perez
  So I would say probably humans by default, or we would just say GitHub users and then decide who that user is.  Okay.

42:00 - Travis Corrigan (matterflowadvisors.com)
  Like our users tend to think about, or the things that, that, that, so the organization was mostly just up to me on the way that I, it was my mental model for the application.  That's where we got that. So that's that. So now you're right up on the context for that.

42:23 - Derek Perez
  Okay, so my thinking here, there's, so reading through the whole doc and seeing, advocating for retros wanting to be in the wiki, what wasn't immediately clear to me is where things like retros would go if we did that in this organization, unless it would be like auth retros, and then a folder.

42:45 - Travis Corrigan (matterflowadvisors.com)
  So, yeah, in the, I would actually make the retro part of the, well, if I was concerned about. Humans, the progressive context for humans, I would put the retro as a section at the bottom, like, inside of the PRD.  Yeah. For that particular thing. We can also put them in the Epic, which may be a better place because it's a little bit closer to where the actual work got done.  Um, it's an additional search tool function, you know, a tool call that the robot needs to do to get to that information.  So there's a little bit of, like, context, expense, you know, tax that we have to pay there. Um, but typically, you know, if I'm thinking about this, that the pattern match from how we were running Agile at Beachbody matters, we would do a retro at the end of two weeks about the sprint.  Um, and that sprint may have more than one Epic in it. Um, and so I guess, and that's just, we did that batching because it was more expensive organizationally to do it in a more granular fashion than that.  Like we were just sort of lazy about it. Now with this, we could be a lot more prescriptive about how precise we want that knowledge to happen.  And so I, I think it's up to you about how you want to think about preserving knowledge and lessons learned from work product produced so that it's more easily accessible to future agents with fresh context windows.  That's it.

44:48 - Derek Perez
  It's all. Okay. That makes sense. So like, for example, the, the granularity, and I don't know, like I said, I told you earlier, I have kind of a problem.  With taxonomy that I want to map to yours. So help me see how this fits. So I have. These PRDs, right?  And what I was doing was migration is an epic in my mind. These are PRDs that when solved, the migration epic is complete.  Okay. Migrating to Medusa, let's say. Yeah. And then in here, I have milestones. And in here are particular features that need to be built.  And these are, guess, feature PRDs, like the shipping system, right? Yeah, right. Then what I did was I said, okay, take this.  And turn it into a plan. And so then it made a plan that mapped to that same PRD name.  Okay. And then this was the complete design plan for satisfying the delivery of that feature. Okay. Right. And then what it did was it made a list of tasks, breaking up what it thought needed to be done in order to deliver that, what I called phase of the plan.  Okay. Right. And then each. Thank you. Phase had its own phase plan, right? And a phase plan was just a space for it to say, like, this is how I think this phase will technically look to satisfy the tasks.  And then at the completion of all tasks and the commits needed to provide what was specified in the plan, I would then consolidate that into a retro like this.  Now, what I immediately learned when I did that was, and so that's, so ritros were like at the end of the delivery of the plan for the feature PRD of all the phases that needed to be delivered.  So where would that fit?

46:42 - Travis Corrigan (matterflowadvisors.com)
  So the current state is we very much solve, we're pretty much pattern match thematically. In terms of order of operations.  Okay. So we would do brainstorm with superpowers. Then we would, and then we save that as a PRD. Um, and then we would convert that into that PRD into a GitHub milestone.  And then the issues, which are the product tickets. So what you have as phases is probably a product issue.  Okay. Um, and then the, the tasks from there would be, um, the tasks that would be in that plan.  I see.

47:58 - Derek Perez
  Yeah. Yeah, yeah, yeah, yeah. That sounds right.

48:01 - Travis Corrigan (matterflowadvisors.com)
  And then the, and then bugs, you know, for any of those dev tasks that produce a bug that needs to be associated with the dev task and the product ticket.  Okay.

48:16 - Derek Perez
  So having that, I think that makes perfect sense. So then based on that taxonomy, I think I would want retros to occur when an epic is completed.

48:27 - Travis Corrigan (matterflowadvisors.com)
  That's correct. Yes. Okay.

48:29 - Derek Perez
  Now the only other addition to that, that wasn't in the system I described for that very first one was the introduction subsequently of the lessons file.  Yeah. And each lesson was scoped to a phase. Okay. so I think that would mean that lesson act accumulation of lessons would occur at the product ticket level.  Do you agree?

48:55 - Travis Corrigan (matterflowadvisors.com)
  Yeah. Okay.

48:57 - Derek Perez
  So product ticket is the acclimation is. The accumulation of lessons, and retro is the accumulation of product tickets and their lessons.  Yes. That's, I think, one for one for what I'm doing. Yes. Okay, sweet. Then that sounds good to me if that sounds good to you.  That sounds really great to me. Okay, great. So then let's see what's next. Ah, yes, one other. Oh, well, what we didn't really solve was where does that live in the wiki?  Lessons. Well, lessons can go in the task. Or in the story.

49:31 - Travis Corrigan (matterflowadvisors.com)
  Lessons can go in the story. It's fine with me.

49:35 - Derek Perez
  But where does the retro go?

49:37 - Travis Corrigan (matterflowadvisors.com)
  Retro would live in the epic itself. Is the epic a ticket? The epic is a milestone. Does a milestone, can you edit a milestone?

49:52 - Derek Perez
  like where, have data? I'm pretty sure it does, yeah.

49:57 - Travis Corrigan (matterflowadvisors.com)
  Let me check real quick. doing. doing. I'm I'm That's what

50:00 - Derek Perez
  That's I wasn't sure on, is like, is that a thing?

50:12 - Travis Corrigan (matterflowadvisors.com)
  Is this a milestone? Milestone, right. No, this is a...

50:22 - Derek Perez
  I thought milestones were just buckets.

50:26 - Travis Corrigan (matterflowadvisors.com)
  They are, but they're...

50:33 - Derek Perez
  Well, they have a readme. They also have a readme.

50:37 - Travis Corrigan (matterflowadvisors.com)
  The project has... I mean, their projects... Oh, oh, oh, sorry.

50:40 - Derek Perez
  I see. Yeah, I didn't think they were issues, necessarily, but... They're not.

50:55 - Travis Corrigan (matterflowadvisors.com)
  Here we go. Nope. Yeah. So here's the milestone. You can edit it, and it's got a due date.

52:10 - Derek Perez
  I don't think that description is going to be enough space.

52:13 - Travis Corrigan (matterflowadvisors.com)
  And then description for...

52:26 - Derek Perez
  I would be a little surprised if this is... , I mean, it just doesn't seem like the right place to me.  Like, I would rather just live in the wiki. Okay. So if we can agree that it would live in the wiki, I just want to know where, based on our tree.

52:42 - Travis Corrigan (matterflowadvisors.com)
  Then it would just be a retro would be a subsection in the PRD. Has a new page under it?

52:57 - Derek Perez
  It can be... you would just add it directly?

52:59 - Travis Corrigan (matterflowadvisors.com)
  Yeah. can it directly or you can add a new page. The add it directly is for the benefit of the humans.  If you were thinking about humans trying to find this thing, if you wanted easier search tree for agents, we could have an additional page.

53:22 - Derek Perez
  Okay. I'm going to bias towards page because I think that's really who's reading it.

53:26 - Travis Corrigan (matterflowadvisors.com)
  Is that cool with you? Yeah, totally.

53:28 - Derek Perez
  Okay. So then another similar thing by the same sort of questions for retros, you referred to something that I really liked, which was decisions and the need for decisions to exist is something that was referenced right there, but then never referenced anywhere else.  And I want to treat that actually as a first class thing. Let me see where it was. Okay. Right.  Okay. A decision shows up, a series of decisions, I'm wondering if you want to adopt a proper decision record standard, and I link to one that exists, called ADRs, that are what, they're called architecture decision records.  And so like, this is a pattern, and probably something Cloud already knows how to do. And so then the question is just, in a similar way that PRDs exist in the wiki, retros exist in the wiki, we could keep decision records of some kind also in the wiki.  But the way that they're different in my mind, is that they might be scoped to a PRD, or a project, or a feature, or they may be cross-cutting.  Yeah. Because they typically operate as like decision tree, like logs. Right. Like we decided, we don't throw errors anymore.  Right? Or something like that. Yeah. And so, what I like about decision records is they typically are sort of a...  A timeline that's irrespective of feature development, but they're referenced there. And so like, it's very common for like ADRs to be like sequentially numbered, for example, because they're just tied to the addition of a decision.  Right?

55:17 - Travis Corrigan (matterflowadvisors.com)
  Yeah. I think this makes sense. Discussions feels like the right place to put this. Yeah. As a thing to link to.  Like when the discussion is closed and decision is made, then we cross-reference it here. Okay.

55:38 - Derek Perez
  So you'd rather use discussions for decision records. I wasn't sure. Like. Like, feel like either to work.

55:56 - Travis Corrigan (matterflowadvisors.com)
  I mean, I think there are decisions that are scoped. the... see It's a keep— to go that. the The PRD level, and then there's decisions that are made sort of more globally, right?  So this is sort of not dissimilar to, like, how do we think about, like, variable scoping? Yeah.

56:17 - Derek Perez
  Theoretically, it would be fine for a PRD scoped one to be in the repository of all decisions because you would just reference them in the PRD like you're doing here.  Right? Like, it doesn't, that's what I like about decision records as a construct, is they're just literally a ledger, and you just point to the ones in the ledger you care about.

56:34 - Travis Corrigan (matterflowadvisors.com)
  Yeah, then that makes sense. So you're thinking, like, one, a...

56:40 - Derek Perez
  Like, it exists outside of the PRD system. Yeah, let's do that. think that's... Okay. Because, but, like, to your point, though, a PRD may introduce a decision record.  Yeah. Right? And that's fine. And it's, a reverse index. That's what I like about this.

56:55 - Travis Corrigan (matterflowadvisors.com)
  Yeah, would say that, yeah, so this is, like, decisions made.

58:01 - Derek Perez
  And why I like this is because like you could allow an agent to decide that we need to be looped in through RFDs.

58:07 - Travis Corrigan (matterflowadvisors.com)
  Yeah.

58:08 - Derek Perez
  And then that would be just like what it goes and does, right? Another option, and I'll be linked to this.  I always, I'm always a big fan of what they do at Oxide. think RFDs are really interesting. In fact, theirs are public.  So you can see some examples of what those are. Let me see if I can find where they put that.  Another somewhere. Because I've seen them and I was like, man, this is really cool. In fact, I remember sending you one.  Because I was like, this is pretty neat. And they like have a little web app for it. That just like documents their decision.  Which may be too heavy handed.

1:00:03 - Travis Corrigan (matterflowadvisors.com)
  think that might be, yeah, I think the intuition here is like, in the same way that, yeah, we may run into this issue where like the Git commits, like letting Claude just write the Git commit messages, could be something way more efficient or effective for like use cases we didn't foresee.  So I would actually be a little bit, I'm okay initially to be biased, to be less prescriptive about this, about the decision log, because refactoring is not hard.

1:00:37 - Derek Perez
  Yeah, like, I mean, even just as a, I don't know if you can still see my screen, but like, the simplest version of an ADR or whatever looks like this, and you just fill in the blanks.  So like, it's like, it can be very simple. Yeah, okay, cool. Right, and so if you want to have a structure to it, it could be very lightweight.  Okay.

1:00:57 - Travis Corrigan (matterflowadvisors.com)
  Right. I was looking at.

1:01:02 - Derek Perez
  Yeah, because like there's a few, like what this is telling you is that there's an ADR and there's like four versions of it you can think about.  There's Markdown Architectural Decision as a standard, and like that template looks like this. Yeah. Right? The one I just showed you before was the Nygaard one.  There's also why statement and other, like people have made other templates, but like, I think we could just like agree on one and then use that and then discussions as the framework.  Okay. And I think like if you wanted to start with the Nygaard ADR, that's probably fine. You can see it at the second here in that sentence, blog post from 2011 suggesting the structure in Markdown.  Got it. Okay. Like that's honestly like pretty light. Yeah, let's just use this one. Yeah, we can start there.  Okay, I like that. You like that. Let's see. Oh yeah, wiki homepage. Only question I had was, is it beneficial to link to the GitHub tracker in this as well?  Since this is kind of a dashboard. Give me a sec. Sure.

1:02:32 - Travis Corrigan (matterflowadvisors.com)
  Okay. All right, down here. For a wiki homepage.

1:02:39 - Derek Perez
  It's like, do you want a link to? Yeah. Okay. That's something we should just add. I don't.

1:02:48 - Travis Corrigan (matterflowadvisors.com)
  Oh, wiki homepage.

1:02:58 - Derek Perez
  Like if it's in progress, it could link to. to.

1:04:00 - Travis Corrigan (matterflowadvisors.com)
  And they have a one-to-one mapping between PRDs, Epyx, and Milestones are all roughly the same.

1:04:08 - Derek Perez
  Is it worth it to just simplify this down to say Milestones then? Or like, why do we need the Epic language?  It doesn't.

1:04:16 - Travis Corrigan (matterflowadvisors.com)
  It was just doing some mapping of Agile concepts to the GitHub primitive.

1:04:22 - Derek Perez
  Oh, okay. Yeah, then that's fine. And that's helpful because this is exactly the problem I was running into in the file system you saw.  Was like being imprecise about that language, I think actually did a net negative to its effectiveness. And I like how much more you're confining to a framework here.  Yeah, thanks.

1:04:40 - Travis Corrigan (matterflowadvisors.com)
  I mean, we'll see how, whether it's too brittle or not. I mean, it's sort of my worry, but we'll, you know.  I think at least to your using language it's been trained on.

1:04:48 - Derek Perez
  So I think it'll, and you are also giving it like a translation table. So I think that's pretty good.  Yeah.

1:04:56 - Travis Corrigan (matterflowadvisors.com)
  And I think, and honestly, in my mind, I'll just call things. you. Thank Milestones. Like, I just, I know the, yeah, this is going be what it's going to be.

1:05:05 - Derek Perez
  So this one, I was in a similar question of overfit, but I guess I forgot that these files live in the repo too.

1:05:14 - Travis Corrigan (matterflowadvisors.com)
  Yeah, yeah, yeah. They're, in fact, this is, although I'm not entirely sure why it decided to do, a story template.  I don't know. For an issue for AI agent consumption, because the AI agent is not going to be like, because I actually deployed that, that one, because I was like, what the  does that look like?  Yeah, it actually makes a form.

1:05:51 - Derek Perez
  Yeah, it makes a form, which is this one here.

1:05:54 - Travis Corrigan (matterflowadvisors.com)
  Yeah. It pops this whole thing open. And I'm like, I don't think an agent is actually going to be filling this thing out.  Well, we are. It wouldn't use that UI, but it might use that as guidance. I think it's probably going to use it as guidance.  So I'm inclined to leave it in there and sort of see what happens.

1:06:09 - Derek Perez
  Well, then the only other thing I was mentioning here was that ostensibly my overfitting problem is back. Yeah, okay.  Is that there's things in here that don't make sense. Okay. I think I'm trying to remember where I saw this.  Yeah. Oh, maybe I'm wrong. Maybe this one didn't. Maybe translation. Like, you know what I mean? Like, there's just some stuff in here.
  ACTION ITEM: Update Claude PM spec: remove Translation field from Story template - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=4008.9999  I would say, like, make sure that all of this feels like it's neutral. Mm-hmm. But actually, looking back at this, I think I must have missed.  I must have misfired this one. Let's see.

1:06:59 - Travis Corrigan (matterflowadvisors.com)
  Yeah. Yeah. I think translation is the only one there that could be possibly unnecessary. Yeah, translation, that's left over from, yeah, we don't need that.

1:07:11 - Derek Perez
  Okay, I think actually looking closer at this, I was wrong, and there's not actually as much here to worry about.

1:07:19 - Travis Corrigan (matterflowadvisors.com)
  The other scenario tracker also does not need to be, well, I don't know, maybe. We did that for humans, because I would have the QA team actually make updates so that I could look at a given product ticket and never have to ask anyone on my team, what's the status of this ticket?  It was always right there.

1:07:38 - Derek Perez
  I think you should keep that, then, because that, I do find pretty regularly that there's going to be things in the acceptance criteria that I've already seen with my version of this, where Claude tells me to go do a manual check, and then it observes what I do.  And I think scenario tracking is fine. I call that manual But I think scenario tracking is the same idea, and that's fine.  So I actually do think you should leave that. Okay, cool.

1:08:07 - Travis Corrigan (matterflowadvisors.com)
  And by the way, scenarios typically decompose to tasks, dev tasks. It's usually the way that my engineers would parse that out.  They're like, okay, cool. So I've got, for a given scenario, they've got like three or four tickets, like dev tasks that they need to do to do certain things.  That's how they did that. In my mind, that doesn't seem right.

1:08:28 - Derek Perez
  I would think of these more as critical user journeys that may cross-cut multiple tasks. Like scenarios? Yeah. Yeah, so one scenario is not one-to-one with a dev task.  Okay, I would agree on that.

1:08:41 - Travis Corrigan (matterflowadvisors.com)
  Yeah, it's a one scenario to many dev tasks assumption.

1:08:45 - Derek Perez
  Okay, yeah, that makes sense to me.

1:08:48 - Travis Corrigan (matterflowadvisors.com)
  And it's also one-to-many in terms of bugs. So one scenario can trigger more than one bug. That makes sense to me.  And I think that might actually be something that we want to explicitly, about was basically.

1:08:59 - Derek Perez
  you. Designate about how, like for this particular document template, it might be good to have very clear instructions about how each of these should be used.  Yeah. You know, because like, I think that that's a, that's very important for it to think about as it's like federating tasks.  Yeah.

1:09:23 - Travis Corrigan (matterflowadvisors.com)
  So what is the desired behavior that we have here? We might, let's just say here on the transcripts, we just have the robot use it.

1:09:30 - Derek Perez
  Well, think you just did. So I think you have it. It was basically like a scenario could be, one scenario could map to many dev tasks or many bugs if identified.  Okay. What I was really calling out was that you might want to evolve additional ones for other sections that you think may be ambiguous.  For example, definition of done, acceptance criteria, when do I use agent instructions, you know, those things. this I don't know the answers to that.  So that's probably something you can work with Claude and Brainstorm. Okay. For DevTask, I think this all looks right to me.  Again, this is scenarios addresses here, so that's another good call out. Yep.

1:10:26 - Travis Corrigan (matterflowadvisors.com)
  Yeah, this makes sense. Yeah, this all makes sense.

1:10:29 - Derek Perez
  Bug Ticket. Objective. Yeah.

1:10:34 - Travis Corrigan (matterflowadvisors.com)
  Any AI agents should be able to read this and know exactly what to build. Fine. I'll have some. I'm just going to be loud.  Oh, okay. Thanks.
  ACTION ITEM: Update Claude PM spec: remove recording link from Bug template - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=4250.9999

1:10:45 - Derek Perez
  Yeah, I think this all looks fine to me. Dunwin seems fine to me. Test guidance is good. Bug Ticket.

1:10:59 - Travis Corrigan (matterflowadvisors.com)
  All right. Bye. Bye. You

1:11:01 - Derek Perez
  Failing scenario, environment, observed behavior, might drop the recording link just because we're not going to have it, expected behavior is good, repro steps is good, root cause, fix guidance, that all looks good.  Retrospective. What I was confused by is like, where are sprints in all of this? Cause this started to talk about sprint retrospective, which made me think this is not right.

1:11:44 - Travis Corrigan (matterflowadvisors.com)
  So we would, yes. So sprint retrospective is like lessons is lessons. And typically, as I said earlier, the reason why we had it at a sprint level, as opposed to right.  The milestone level is because we just did not have the time to have engineers sit and enumerate everything the way that AI can.  Okay. So what we should have instead is a lesson attempt?

1:12:17 - Derek Perez
  Well. So this doesn't need to be a.

1:12:20 - Travis Corrigan (matterflowadvisors.com)
  We should kill this.

1:12:21 - Derek Perez
  Yeah. Yeah. Because what we would say is lessons is a procedure done to a story ticket. I think, right?  Yeah.

1:12:31 - Travis Corrigan (matterflowadvisors.com)
  So we need to refactor the retrospective template for E to not be at a sprint level. We need it to be at an epic level.  But I don't even think we would do.

1:12:44 - Derek Perez
  It wouldn't be an issue. Right. So like, let me, let me go up here. You're right. You're right. Yeah.  Just to make sure I've got the language right. Yeah. A lesson would be like the last comment on a product ticket before it's closed.  right. closed. But Okay. I think. That's my add to lessons, .md. And then the retro is added to the wiki at the end and consumes all of the MCPs out all of the lessons and looks at all the commits and all the tickets.  You know what?

1:13:19 - Travis Corrigan (matterflowadvisors.com)
  Let's just have Claude tell us what it thinks would be. Give us some options here, I think. because at the end of the day, really, all we give a  about is whether or not the model is learning from past work, from past models, and applying that effectively, right?  I think that's right, but this is a natural place for it to live.

1:13:45 - Derek Perez
  The lesson level.

1:13:46 - Travis Corrigan (matterflowadvisors.com)
  The lesson level out of product tickets.

1:13:50 - Derek Perez
  Yes, because it was like, okay, so I did all these tasks, I fixed all these bugs, all these scenarios have been met.  That's where, that's the point in my system where I did the lessons learned. And then I was doing that at the phase level, remember?  And we both agree that product ticket story was essentially a phase. Yeah, you're right. So what we would say is that's not an issue template then?  No. Because it would never live at the top level. Correct. Okay. And then the retro stuff also wouldn't exist.  That would be a wiki thing. Correct. So lessons.

1:14:26 - Travis Corrigan (matterflowadvisors.com)
  And this goes here.

1:14:36 - Derek Perez
  Well, you don't have to edit the issue. could literally just append it as a comment.

1:14:40 - Travis Corrigan (matterflowadvisors.com)
  Oh, okay. Cool. Yeah. We would just append it as a comment.

1:14:43 - Derek Perez
  So this is more, we'll get to this, I think, in the next section, but this is more of like a behavior.  That's what I was saying. It's more of a behavioral thing than it is a template thing. Okay.

1:14:52 - Travis Corrigan (matterflowadvisors.com)
  Right. So you don't need to add it to anything.

1:14:54 - Derek Perez
  All we really need to do is delete 4E. Okay. Hey, Wendy. Thank you. Thank you. Thank you. So moving on to versioned epics, one thing I was noticing was that I would suggest that we define constraints on what an acceptable epic name looks like.  For example, I've seen auth v10 show up, which I believe is mapping down below to epic colon auth. Is that right?  Yes. So then my assumption is that they're going to be lowercase. And if there were any spaces in that sentence or in that, in that term, they would be kebab case.  Right. So that's ambiguous at the moment. And so we just want to define some rules to say an epic name that looks like this is like a title or a label would be constrained or would be synonymous with these rules.  Okay.

1:15:57 - Travis Corrigan (matterflowadvisors.com)
  Additionally, we could instead say...

1:16:00 - Derek Perez
  There's an explicit property of like an Epic identifier, which is disjoint from the Epic name, but that just requires more bookkeeping.  So I wasn't sure which way you thought was better. Or like, can you just live with it being one-to-one and say, like a milestone has to be lower kebab all the time?  Yeah. Okay. What?

1:16:34 - Travis Corrigan (matterflowadvisors.com)
  Like, like in the title of the milestone? I suppose.

1:16:37 - Derek Perez
  Like, that's where, that's what I was trying to figure out was like, Epic name showing up as capital A auth is one word, right?

1:16:44 - Travis Corrigan (matterflowadvisors.com)
  Yeah, no, we don't have to do that. We can do, where the  is it?

1:16:48 - Derek Perez
  Well, it's just really a question of like, what feels ergonomically good. But I would think that you'd want to make sure that it's compatible with lower kebab rule.  So either it can be resolved to that, or you just use that. It would be what?

1:17:07 - Travis Corrigan (matterflowadvisors.com)
  Epic? Dash.

1:17:10 - Derek Perez
  Auth. Well, I mean, let's say that the milestone was called Auth-With-Google, for example, for an Epic called Auth-With-Google.

1:17:24 - Travis Corrigan (matterflowadvisors.com)
  Okay.

1:17:25 - Derek Perez
  And then in your full naming convention, it would be Dash-V, or Dash-V major number with an optional dot minor number.
  ACTION ITEM: Define Milestone/Epic naming conventions; implement conversion in decomposition skill - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=4656.9999  You may also want to require always to have a minor zero, just to make parsing simpler. Okay.

1:17:47 - Travis Corrigan (matterflowadvisors.com)
  Okay, so the decision is, use kebab case. Lower kebab case.

1:17:56 - Derek Perez
  Lower kebab case.

1:17:57 - Travis Corrigan (matterflowadvisors.com)
  When naming milestones. Okay. Based on PRDs. Effectively, the PRD title and the milestone title just need to be the same.

1:18:08 - Derek Perez
  They do, but the problem is if that's what you want, then you have to, one of them has to suffer is what I'm saying, or you have a conversion.  Oh. You know what I'm saying? So like, if you're comfortable with auth underscore auth dash with dash Google showing up as your PRD title, then who cares?  But if you don't like that as a human, there needs to be a way for you to communicate that...  This maps to this through some convention. Like, if it's auth with Google and title case with spaces, then you could transform that to lower kebab case.  See what mean?

1:18:42 - Travis Corrigan (matterflowadvisors.com)
  Yeah, I think that we can just put inside of the decomposition skill. Yeah, that's fine.

1:18:51 - Derek Perez
  I'm just saying it's not specified. So as long as it's specified somewhere, I don't really care what the decision is.  I just think we should be clear about We specified what the rules are.

1:20:07 - Travis Corrigan (matterflowadvisors.com)
  Hold on a second. I gotta check whether or not this is. Hello, this is an automated call from Google.  A password reset request has been initiated from an unrecognized device in Frankfurt, Germany. If this was not you, So anyway, just defining what effectively the style guide is for Epic names and how they map to GitHub like you have here is good.

1:20:49 - Derek Perez
  We should just say, like, what is it doing? Correct. Just so that it's clear for agents and stuff. Sound good?  Thanks. Thank I the passage of time is a human thing. For sure. But like the agents are doing all this work, so I don't think it needs to care what it's fitting in a week.  You care as an observer. Yeah. But it doesn't.

1:22:15 - Travis Corrigan (matterflowadvisors.com)
  Okay.

1:22:17 - Derek Perez
  I think we actually addressed this one elsewhere. was like, where's the explicit step for lessons? I think we've talked about that.  But we may need to add it to this workflow list, but just to say that it would go at the end of the completion of a story.  Right. So I'll just put that in. Where? There it is.

1:22:40 - Travis Corrigan (matterflowadvisors.com)
  Number eight. It also thinks that the human should update the scenario acceptance tracker on the parent story, which is not true.  Okay.

1:22:51 - Derek Perez
  All Why don't you address that? And then I'll just add, we believe lessons are encoded. Into the completion of a story issue before it is closed or resolved, before it is resolved.
  ACTION ITEM: Create sub-agent to update scenario acceptance tracker on parent Story - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=4992.9999  Yeah, and then.

1:23:23 - Travis Corrigan (matterflowadvisors.com)
  So do you think we should have a dedicated subagent with a clean context for this? Or which is the part?  Updating the acceptance tracker, my parents story.

1:23:36 - Derek Perez
  Probably. I don't know, can it?

1:23:42 - Travis Corrigan (matterflowadvisors.com)
  Yeah, because all it wants to do is just go through the tickets and just like. Run the evaluations.

1:23:47 - Derek Perez
  Yeah, that's probably right then.

1:23:49 - Travis Corrigan (matterflowadvisors.com)
  Update markdown on a  document. Okay. I'll do that.

1:23:52 - Derek Perez
  So this next one, like I was saying, there's a pretty major gap on just pull requests. So a And I think we need to figure that out.  We could also spike on it since there's so many other things to finish right now and just call that out for the next revision of this.  But what I think needs to happen is Claude would publish a branch which would then construct a pull request and all the commits within that range would go into the pull request, right?  Exactly.

1:24:57 - Travis Corrigan (matterflowadvisors.com)
  Okay. Okay. Okay. Nothing. I need to take action on right now. Okay.

1:25:03 - Derek Perez
  So what I think the workflow is going to look like, right, is you're in, you have a sub, you have something writing code into a work tree.  It's publishing changes as a pull request. And I think the ergonomics of this will be, we would then look at pull requests, right?  Right. So we're going to give inline feedback. Maybe we're giving line by line feedback like you would do for a human or a comment feedback at the end or some combination of these things.  Right. Yeah. So like there's going to be some like fairly complex artifact coming back to it that it's going to need to effectively wait for and then review, make changes and submit back.  Yeah. So I think a clever way to deal with this, and this is something we're going to have to prototype, but I think what I would do is I would say when it's done, it's published the piece.  PR to you, and it's waiting for review, it should potentially spawn a haiku sub-agent that is just polling for changes.  Yeah. Like with a bash loop, right? And so like every 30 seconds or something, or every minute, it loops in bash and it goes, GitHub API request, has the PR moved at all?  Yeah. And then when it does, it would then pull down all of, it would do, you know, whatever it does with the GitHub command line to like get the data.  Sorry, should I look at this? No, keep going. Okay. It will download, it will download whatever the diffs, you know, whatever the comments from the review process from the human were, and then it would, it would kill the sub-agent and then read that information.  Right, then ostensibly then it could do the changes, push the changes, and you should see them show back up in GitHub.
  ACTION ITEM: Review Derek's PR prior art; incorporate into PR automation plan - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=5214.9999  Yeah.

1:27:00 - Travis Corrigan (matterflowadvisors.com)
  I think that would work.

1:27:03 - Derek Perez
  Yeah, I think that sounds right.

1:27:05 - Travis Corrigan (matterflowadvisors.com)
  I just sent you something that describes, I think, probably 60% of that. So it's worth going through prior art here.  Yeah. Because prior art is actually incorporated into that piece of it. Um, and some of that is skills that have been developed for Cloud PM that are, I think, supersets on top of, um, superpowers.

1:27:35 - Derek Perez
  Okay.

1:27:36 - Travis Corrigan (matterflowadvisors.com)
  So superpowers has in its skillset, um, dispatching parallel agents, uh, receiving a code review, requesting a code review,  like that.  Oh, it does. And it's got, yes, and it's got code reviewer agents, uh, and. Like, it's got its own whole  thing.

1:28:03 - Derek Perez
  So here's my only concern, is I think it has to do with where that happens. Now, when it requests a code review, does it expect you to do it at the terminal that you're at, or through GitHub?

1:28:19 - Travis Corrigan (matterflowadvisors.com)
  At the terminal that you're at. That, to me, was the understanding as well, which I think is limiting.

1:28:25 - Derek Perez
  You have a code reviewer here.

1:28:28 - Travis Corrigan (matterflowadvisors.com)
  Yeah, let me see what this says. There's the, all that. Yeah.

1:28:32 - Derek Perez
  Go to skills. Receiver request.

1:28:36 - Travis Corrigan (matterflowadvisors.com)
  You've got using Git work trees, test-driven development. Yeah, yeah, All that stuff. And then the agents, oh, it like they have a code reviewer one, but they also have this skill that I think they dispatch, dispatching parallel agents.  Yeah. Thank So it's effectively saying, when you have two things, it's telling the Cloud Code main session to spin up as many agents as necessary on the tasks at hand.  Yes. So it's dispatching in parallel. So it's not being really prescriptive about the agent itself. And it looks like it's running that as part of the Cloud Code session.  Yes.

1:29:30 - Derek Perez
  Now, there's one caveat problem, I think, with this is it can't invoke CodeReviewAgent from here because an agent can't run another agent is a limit in their system, which I've discovered the hard way.  Sure.

1:29:47 - Travis Corrigan (matterflowadvisors.com)
  So it can only go one level deep and back.

1:29:50 - Derek Perez
  And so what it's going to have to do is dispatch in parallel fixes, and it's going to have to do another dispatch of review tasks, which it can do.  Right? Right. Right. Right. Right. But then if you need to go any further, like what I'm worried about is this loop situation, because the real core question, I think on my mind, and I'm curious what your perspective is, is do we want code review ergonomics for the human to be on github.com?

1:30:23 - Travis Corrigan (matterflowadvisors.com)
  Oh, where I'm looking at the diffs? Yes. And where do you give the feedback?

1:30:29 - Derek Perez
  You're inlining, adding comments, like, because what I'm saying is like, in my experience as like a developer, it's really common.  I don't know if you can see my screen right now, but it's really common to go through this. This is the UI, right?  Yeah. And then you go into here, and you're like, I'm going to add a line like, this is .  Right? And then start a review. And then at the end of this process, you collect a bunch of comments.  And then when you do that, they get added. It is like a conversation history in this list. If this and I have code owners, when I approve it and I'm in the code owners list, then the agent can merge the branch.  That's the workflow. Got it. So then the question is, okay, I have changes I want the agent to do.  So I make my review, I add the comments, I hit request changes. How does the Claude code session know what to do next?  Yeah, that's a great question. So my assumption, and this is the hypothesis I have, and I'd love to see what brainstorming thinks about this.  I think what I would do is I would spawn a sub-agent for every PR that it submits, and I would pull the GitHub API looking for changes in the conversation for this ID.  Okay. And then when it gets that, it may be able to use this review over here, the code review reception thing.  Right? So like what we're talking about is, how do I give it feedback through github.com? How does it download that?  It's back to the branch. It can do all of that. So I think that's the loop. And then it starts the haiku thing and pulls again for new changes.

1:35:11 - Travis Corrigan (matterflowadvisors.com)
  This seems like something that probably could use a push rather than a pull with GitHub actions and hooks. I don't know that you can go that direction.

1:35:25 - Derek Perez
  Oh, okay. Right. Because GitHub can't ping your computer. If it could, I agree. Right. But that's exactly the problem is GitHub has no way to talk back to your Claude.  Right. Right. And so I think it just has to pull. And so what I do is use the dumbest model, the cheapest model possible, and just let it pull every couple minutes.  Like a fake inbox. Okay. I think that'll work. I actually think it might work. And so that's why, like, I'm kind of curious to see if we can get Claude to build that system.  And we would just think of it as a sub-agent. fine. It's fine. fine. A subagent PR poll. Yeah. And it's like, I've done work.  I've committed it. I pushed it to branch. I'm going to watch the branch now. I'm going to watch the PR until you touch it.  And then when you touch it, I'll pull the latest information and I'll do a local rev. Yeah. The other cool thing, if that actually does work, we can run Claude off of our laptops.  At this point. Right. Yeah. Right. It could run in a code space. could run on another machine. could run in the cloud.  doesn't matter anymore because we're not even looking at the code. Outside of GitHub. If this works. Yeah.

1:36:33 - Travis Corrigan (matterflowadvisors.com)
  Okay. So the decision is we're going to use superpowers as to the best of our ability. We're going to do PRs inside of GitHub.com and we're just going to see what happens.

1:36:45 - Derek Perez
  Yeah. How do we, how do we, the ambiguity is how do we get Claude back in that loop? Yeah.

1:36:50 - Travis Corrigan (matterflowadvisors.com)
  And we'll just sort of learn and it'll probably require some invocations manually and then we'll figure out a way to do that automatically.  Yeah. One thing I want to, uh, it's

1:37:00 - Derek Perez
  What explicitly say on the transcript is we should not use the Claude GitHub actions. Okay. They are not good.  Right. Or they're not for this. Yeah. To my knowledge, that the GitHub actions for Claude are like a separate thing, sadly.  And I hope they fix this one day because this is honestly like pretty important. Yeah. So we can move on.  We talked about retro to death. I think we're good. Other than like explicitly defining how the retrospective process works as a skill, but I think it's a skill.
  ACTION ITEM: Finalize Claude PM spec in Google Doc; close comments; copy to MD; schedule CloudCode brainstorm w/ transcript - WATCH: https://fathom.video/share/vHSNy5xFB_v61DAC74xCu-qFStLAzfec?timestamp=5857.9999  Okay. So it may not belong in this doc. And that's it. Okay. Rod. All right.

1:37:48 - Travis Corrigan (matterflowadvisors.com)
  I will do. We'll use this. I'll go through the the comments. I'll So action items for me are go through the comments and make edits to this where necessary.  I will close out comments when they're done and then copy and paste this back into the markdown document in GitHub inside of the Claude PM repo and then do a brainstorming session where I ask Claude Code to take this and the transcript and extract the transcript and then make updates to Claude PM accordingly.  Awesome. I think that's great. This is really exciting.

1:38:44 - Derek Perez
  Hell yeah. Do you want to end recording? Yeah. Give me a second.