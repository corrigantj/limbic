# Claude PM Skill Review Transcript

Impromptu Google Meet Meeting - February 25
VIEW RECORDING - 24 mins (No highlights): https://fathom.video/share/Jjt-PJC-oEdMEwiR6f7yN5skps-Do6Nu

---

3:00 - Derek Perez
  The PR would close, and that task branch would be merged into the feature branch in a rebase style. Got it.

3:09 - Travis Corrigan (matterflowadvisors.com)
  I just want to make sure I understand this correctly, because it seems like there's actually two waves of PRs, but maybe I don't see this correctly.  So obviously all the agents who check out work trees for a feature branch are not going to be done at the same time.  So some people are going to be done sooner rather than later.

3:32 - Derek Perez
  Yes.

3:33 - Travis Corrigan (matterflowadvisors.com)
  And those PRs will start trickling in, those like mini PRs, task level PRs, work tree level PRs. And so we want humans to review that, right?  And they'll be reviewing and approving those one at a time. And then there will be a like, okay, cool.  The feature branch is now consolidated. So we spread out the twigs as work trees and then bring. And twigs back to the branch, feature branch.  Now we have a second PR around feature branch back into main. Correct. And we also want the polling agent to be attentive to that and alerting the human for a final review.  Yes. And ensuring that the rebase and merge back to the non-squashing, back to main, is going to go well.  And we do that and then we run the retrospective. Do you want to run the retrospective before or after the PR?  Probably after.

4:46 - Derek Perez
  As part of it. So I would say we do the final, in that final PR consolidation, we could do a single commit that's, well, the retro doesn't get checked in, in a conventional sense.  It's in the wiki, which I guess I've learned is a. Repo of some other kind. I don't know. We'll find out.  Yeah. So the retrospective should be written.

5:09 - Travis Corrigan (matterflowadvisors.com)
  Probably afterwards because we want the commit or the merge rebase from feature into main. We want that present as part of the commit log or the merge log or whatever.  Yeah, I guess that's true.

5:25 - Derek Perez
  the retro, right? Yeah, I think what we might do is say like either as part of the description of that final merge or a comment of that final merge.  Because like the thing that's a little bit confusing in this architecture is a pull request isn't a true git artifact.  It's a GitHub artifact. And so when you do that, like it, it's a shadow. It's like a mirror structure with a branch, but it's like extra metadata that branches don't have.  Okay. Like comments and descriptions and all that stuff, right? So I think it's safe to say once we've merged.  Okay. That PR, it can no longer change. And then essentially the retro could start from that basis and then be annotated for the historical record.  Yeah. And like, that's, that's fine. So like the exact order of operations is actually kind of irrelevant, I think.  Yeah. Because in a similar way that we've talked about the need for a PRD to become published or whatever we landed on instead of frozen.  Um, it can't change anymore. Right. And so we want the retrospective to be based on a interval of commits that can no longer be added to.  Yeah. Okay. So I think that's fine. But that's where like the one thing that I was tripping up on, on the existing for a gateway router thing was that it really thinks that it seems to think there's one PR.  And so I want to make sure that to actually leverage, um, parallelism that. We would need to make sure that there is probably a second level of indirection.  The other thing that comes to mind is, as we're doing minor versions of PRDs, that feature branch may not have been merged yet.

7:14 - Travis Corrigan (matterflowadvisors.com)
  Right?

7:16 - Derek Perez
  And so that's where, in my mind, the feature branch pairing with the PRDs, like, top line major version is probably more important because we may decide, like, oh, we forgot a thing after we went through that cycle, and now we need an additive minor revision PR, or PRD.  Yeah. And then additional branches back to the feature branch so we can merge the major version. Okay. That's what I was starting to think through, and does that kind of map to your thinking?  It does, absolutely.

7:47 - Travis Corrigan (matterflowadvisors.com)
  Yeah. Yeah, it's basically a bunch of fractals, and then we bring them back together, and then we... We merge it in.

9:00 - Derek Perez
  Enforces auditing.

9:02 - Travis Corrigan (matterflowadvisors.com)
  Yes. Yeah.

9:03 - Derek Perez
  And so that's like no matter what, like I think that would be, that's like just as good standard practice for a number of reasons.  And it will enforce that you can't have like a rogue agent that just pushes something to main. Yes.

9:15 - Travis Corrigan (matterflowadvisors.com)
  Without review, getting out of that process.

9:18 - Derek Perez
  Yeah.

9:24 - Travis Corrigan (matterflowadvisors.com)
  Yeah, it walked me through a lot of this around Maine and like what it means, all that stuff. So I think I have a good, you know, mental scaffolding around the life cycle of this.  And so we kind of get into the nits around our style and what we think is good. I'm tracking pretty well.  And for whatever I don't, I can just literally use this transcript and just be like, okay, here's what we talked about.  Now, now . Explain more of this to me. Yeah, that makes sense.

10:02 - Derek Perez
  And I think like that's the general premise is that the branch acts as the basis for a pull request to show all the, and a pull request is effectively alive.  So every time you make additional commits to your branch, it just automatically appends to the pull request as a mutable thing.  Okay. And then once you do the review, that's when you can have a decision that occurs that pushes the outcome of the PR somewhere, right?  And the reason why that matters is like, let's say, you know, you have a branch off of an issue.  You do some work, the human reviews it and says, no, this isn't quite right. That introduces more commits within that timeline, right?  So it's like the first commits are like, I did a thing. And then human responds, here are things I need changed.  Agent says, okay, here's some more changes. There are additional commits that follow up after that. But the subset of files doesn't like it necessarily increase or decrease.  know what I mean? Yeah. So like the commits are truly just like.

12:00 - Travis Corrigan (matterflowadvisors.com)
  You have to recover from that. And that includes probably the juiciest lessons learned. So I think that I think waiting to do the retro after the feature branch gets merged back into main is probably smart because we want to, and it's easier to do with Matterflower, right?  Because all I'm dealing with is like YAML and Markdown that doesn't actually run in an engine somewhere, right? It's not like code that actually runs and gets served, but that's going to change, you know, as time goes on.  So designing for a more broader use case is probably good.

12:39 - Derek Perez
  Yeah, and I think that's fine because like the initial pass and like the retros don't have to be frozen necessarily, right?  So like I would expect that the first pass, like the first draft of that would just be simply about process success.  Like did we have, what issues did we come into that differed from like the design, the technical plan, and the...  Execution from manual tests or any kind of QA. And then if there's additional stuff, pass that in the production deployment side of the house.  You could just go back to that retro and update it. Yeah.

13:12 - Travis Corrigan (matterflowadvisors.com)
  Right.

13:13 - Derek Perez
  With like, here's some additional stuff that we discovered after deployment. And then we could have, we just add that in after the fact.  Seems fine to me too. Right. That's just like where, that's where knowledge, that's where retrospective knowledge would live, regardless of when it occurs.  Right. So it starts with the delivery knowledge. And then if there's any additional integration lessons learned, they could just go back there.  Because that's where we're storing that knowledge now. Yeah.

13:43 - Travis Corrigan (matterflowadvisors.com)
  Okay. Okay.

13:45 - Derek Perez
  That sounds good to me. That sounds good. Do you want me to look while we're on camera at the other ones?

13:53 - Travis Corrigan (matterflowadvisors.com)
  Sure.

13:54 - Derek Perez
  4B, PM structure, PRD to GitHub artifacts. Um, parse PRD, file, read config, convert naming, create update wiki as needed, epic labels, taxonomy, create milestones.
  ACTION ITEM: Send full PM plan to Derek for feedback - WATCH: https://fathom.video/share/Jjt-PJC-oEdMEwiR6f7yN5skps-Do6Nu?timestamp=850.9999  This all seems fine. I don't see anything. This just seems kind of mechanical about what it's doing, which seems okay.  Yeah.

14:21 - Travis Corrigan (matterflowadvisors.com)
  This isn't the whole plan, by the way, and I can get you the whole plan later, but it's asking for feedback.

14:26 - Derek Perez
  Yeah.

14:27 - Travis Corrigan (matterflowadvisors.com)
  It's just giving me, no, it actually just, I'm using brainstorming and brainstorming just gives me the design section by section.

14:34 - Derek Perez
  Actually. Yeah. Okay.

14:35 - Travis Corrigan (matterflowadvisors.com)
  This, this feels like a really good meaty part to provide feedback on. Um, so because really this is, this is the user flow.  Um, and just by the side note, a little bit of like Travis's product brain going like, Oh, I'm noticing a pattern here of like, what is the, like the new user flow, the new interaction flow is what is the.  It's a of skill invocations that you need to do in a main session that should probably spawn a sibling agent to do those things.

15:13 - Derek Perez
  Yeah.

15:14 - Travis Corrigan (matterflowadvisors.com)
  And then that agent can access probably larger skills if needed, but there's these sort of invocation, like agent invocation things.  So this is sort of really top to bottom, you know, the first thing that we would do is, I'll have to ask when we're going to be using using PM, but really the brainstorming is where I would start anytime I have a new thing.

15:48 - Derek Perez
  It seems, it seems to me like you would say using PM would kick off this workflow and then it would start brainstorming with you.  Yeah. It feels like that's like I'm mounting the PM skillset. And then it goes.

16:00 - Travis Corrigan (matterflowadvisors.com)
  I think you're right about that. That wasn't clear to me, so I didn't want to do that. But yeah, so effectively using PM.  So this is like the order of operations. And then we go through like the brainstorming thing.

16:11 - Derek Perez
  Yeah. And then when the brainstorming plan's good, we're like, all right, great.

16:14 - Travis Corrigan (matterflowadvisors.com)
  We'll do PM structure.

16:17 - Derek Perez
  Well, yeah, I guess like that makes sense to me because it's just strange because in, I don't know if it's just using your syntax for PM colon dispatch, PM colon review, because then down below, you can see that actually kind of lines up, but they use dashes instead of colons.  And I think the reason for that is because I think that Claude skill plugin skills uses the colon for namespacing.  It does. Yeah.

16:46 - Travis Corrigan (matterflowadvisors.com)
  So yes, that's correct.

16:47 - Derek Perez
  So I think it's just confused and that might be something you need to clarify. Because technically, think it would be based on your repo, it'd be claw dash PM colon skill.  Yes. And so there might be some naming stuff you want to change a little bit and just have it do a sanity pass on how it's referring to itself.  Okay. Because I think that would be the way I'd do it. Sounds good.

17:23 - Travis Corrigan (matterflowadvisors.com)
  So yeah, PM structure looks okay to me.
  ACTION ITEM: Add comment to PM plan re: Must Read handling - WATCH: https://fathom.video/share/Jjt-PJC-oEdMEwiR6f7yN5skps-Do6Nu?timestamp=1057.9999

17:27 - Derek Perez
  PM dispatch, read. Skip issues with meta ignore or meta. So it says, it's interesting. says skip issues with meta ignore or meta must read.  Must read is informational and not a work item. So it's just skipping must read. Oh, interesting. Which I don't know if that's good or bad.  So you might want to raise that as like, when does must read happen then? Okay. If it must be done.

17:54 - Travis Corrigan (matterflowadvisors.com)
  Okay.

17:56 - Derek Perez
  I'll add a comment for that. When does must read. Read, happen, if it must be done in the cycle.  Handle sub-issues hierarchically, token-based sizing awareness, code owners look up, agent prompts, looks right, PM status, moderate update core dashboard, logic preserved.  Collect lessons. Yeah, that looks right. I'm a little confused because integrate feels like it should come after PM review in this list, but maybe it's just out of order here.

18:49 - Travis Corrigan (matterflowadvisors.com)
  Which one?

18:50 - Derek Perez
  So 4E and 4F are out of order, I think, because you would do PM integrate is, I think, kind of like the finalization step of a milestone.  a deal. 4E 4F But 4F is like a review process. Yeah, this makes sense. think that just might be like it put it in a bizarre order, but I'm going to read review first and then go look at integrate.  So review says entirely new skill handles the human review loop triggered invoked after PM dispatch agents have created PRs or anytime PRs need review attention.  Identify open PRs. Oh, it's after PM dispatch. It's after dispatch, but the way that it's showing up in here.  Is these, yeah.

19:35 - Travis Corrigan (matterflowadvisors.com)
  So we should like, so the order of operations is PM dispatch, PM status if needed. Yeah. Then PM review.  Yeah.

19:48 - Derek Perez
  Then PM integrate.

19:51 - Travis Corrigan (matterflowadvisors.com)
  Then PM review again.

19:54 - Derek Perez
  Well, no, see, I think from my read, integrate is like the end. Yeah. Polling resumes. On approval, if a code owner's approval received or reviewed approved without code owner's requirement, mark PRs ready to merge.  This is where we might need to really be explicit with like the merge point. The merge target is the feature branch, right?  And then that's why I was, this is exactly why I'm calling this out because then merge and close, or sorry, PM integrate is about then merging the feature branch, which has had all of its subtask branches and work trees merged into it.  Now we're doing one atomic connection back to the main branch, and then we're closing out the work, and then we're doing the retrospective.  Yeah, okay. But on that same note, PM review, I think needs to make sure that as it's merging that into the feature branch, that's where I expect the lessons learned of that particular work iteration to be captured.  you. Thank At the PR that was merged into the feature branch, right? This is equivalent to lessons.markdown as I go, and how that gets brought into the consolidation of the retrospective, because it can quickly look at basically a micro retro of just that one branch, of just that one PR.  Like, how did implementing this task go? Yes. went well? What went wrong? What needs to change in the next one?  Got it. And then, so it gives it kind of a, like a tree, right? As it's reviewing all the diffs, it can also look at like what it thought at the time.  Yeah.

22:40 - Travis Corrigan (matterflowadvisors.com)
  So I think that's good.

22:41 - Derek Perez
  And then PM implementer agent template, significant rewrite. Oh, thanks. Check agent queue for agent ready tasks. Okay. The video recording.  All right, hold on a second.