import credits.aleo;
program guarded_feedback_0_3.aleo;


struct Report:
    id as field;
    security_deposit as u64;
    block_height as u32;
    content as field;
    votes_yes as u128;
    votes_no as u128;
    voting as u32;
    accepted as boolean;
    rejected as boolean;
    solved as boolean;
    comment as field;
    rewards as u64;
    claimed as boolean;

struct Settings:
    ownedby as address;
    voting as u32;
    deposit as u64;

record user:
    owner as address.private;
    amount as u64.private;


mapping reports:
	key left as field.public;
	value right as Report.public;


mapping counter:
	key left as u8.public;
	value right as u128.public;


mapping counters:
	key left as u128.public;
	value right as field.public;


mapping settings:
	key left as u8.public;
	value right as Settings.public;

function configure:
    input r0 as u32.public;
    input r1 as u64.public;

    finalize self.caller r0 r1;

finalize configure:
    input r0 as address.public;
    input r1 as u32.public;
    input r2 as u64.public;
    cast r0 r1 r2 into r3 as Settings;
    set r3 into settings[0u8];


function submit:
    input r0 as credits.aleo/credits.record;
    input r1 as address.public;
    input r2 as address.public;
    input r3 as field.private;
    input r4 as u64.private;
    input r5 as u32.private;
    hash.bhp256 self.caller into r6 as field;    hash.bhp256 r6 into r7 as field;    add r3 r7 into r8;
    hash.bhp256 r8 into r9 as field;    call credits.aleo/transfer_private_to_public r0 r2 r4 into r10;
    output r10 as credits.aleo/credits.record;
    output r9 as field.private;

    finalize r3 r4 r9 r5;

finalize submit:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as u32.public;
    get settings[0u8] into r4;
    is.eq r4.deposit r1 into r5;
    assert.eq r5 true;
    get.or_use counter[0u8] 0u128 into r6;
    add r6 1u128 into r7;
    set r7 into counter[0u8];
    set r2 into counters[r7];
    add block.height r3 into r8;
    cast r2 r1 block.height r0 0u128 0u128 r8 false false false 0field 0u64 false into r9 as Report;
    set r9 into reports[r2];


function yes:
    input r0 as field.private;

    finalize r0;

finalize yes:
    input r0 as field.public;
    contains reports[r0] into r1;
    is.eq r1 true into r2;
    assert.eq r2 true;
    get reports[r0] into r3;
    is.eq r3.accepted false into r4;
    is.eq r3.rejected false into r5;
    and r4 r5 into r6;
    assert.eq r6 true;
    gte block.height r3.voting into r7;
    gt r3.votes_yes r3.votes_no into r8;
    ternary r8 true false into r9;
    ternary r8 false true into r10;
    ternary r7 r9 false into r11;
    ternary r7 r10 false into r12;
    add r3.votes_yes 1u128 into r13;
    cast r3.id r3.security_deposit r3.block_height r3.content r13 r3.votes_no r3.voting r11 r12 r3.solved r3.comment r3.rewards r3.claimed into r14 as Report;
    set r14 into reports[r0];


function no:
    input r0 as field.private;

    finalize r0;

finalize no:
    input r0 as field.public;
    get reports[r0] into r1;
    is.eq r1.accepted false into r2;
    is.eq r1.rejected false into r3;
    and r2 r3 into r4;
    assert.eq r4 true;
    gte block.height r1.voting into r5;
    gt r1.votes_yes r1.votes_no into r6;
    ternary r6 true false into r7;
    ternary r6 false true into r8;
    ternary r5 r7 false into r9;
    ternary r5 r8 false into r10;
    add r1.votes_no 1u128 into r11;
    cast r1.id r1.security_deposit r1.block_height r1.content r1.votes_yes r11 r1.voting r9 r10 r1.solved r1.comment r1.rewards r1.claimed into r12 as Report;
    set r12 into reports[r0];


function respond:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;

    finalize r0 r1 r2 r3 self.caller;

finalize respond:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;
    input r4 as address.public;
    get settings[0u8] into r5;
    is.eq r4 r5.ownedby into r6;
    assert.eq r6 true;
    get reports[r0] into r7;
    is.eq r7.accepted true into r8;
    is.eq r7.rejected true into r9;
    or r8 r9 into r10;
    assert.eq r10 true;
    add r7.votes_no 1u128 into r11;
    cast r7.id r7.security_deposit r7.block_height r7.content r7.votes_yes r11 r7.voting r7.accepted r7.rejected r3 r1 r2 r7.claimed into r12 as Report;
    set r12 into reports[r0];


function claim:
    input r0 as field.private;
    input r1 as field.private;
    input r2 as u64.private;
    hash.bhp256 self.caller into r3 as field;    hash.bhp256 r3 into r4 as field;    add r1 r4 into r5;
    hash.bhp256 r5 into r6 as field;    assert.eq r6 r0;
    cast self.caller r2 into r7 as user.record;
    output r7 as user.record;

    finalize r0 r2;

finalize claim:
    input r0 as field.public;
    input r1 as u64.public;
    get reports[r0] into r2;
    is.eq r2.accepted true into r3;
    is.eq r2.rejected true into r4;
    or r3 r4 into r5;
    assert.eq r5 true;
    is.eq r2.claimed false into r6;
    assert.eq r6 true;
    is.eq r2.security_deposit r1 into r7;
    assert.eq r7 true;
    cast r2.id r2.security_deposit r2.block_height r2.content r2.votes_yes r2.votes_no r2.voting r2.accepted r2.rejected r2.solved r2.comment r2.rewards true into r8 as Report;
    set r8 into reports[r0];
