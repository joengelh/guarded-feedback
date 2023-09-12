program guarded_feedback.aleo;

struct Report:
    id as field;
    security_deposit as u64;
    block_height as u32;
    content as field;
    vote_yes as u128;
    vote_no as u128;
    accepted as boolean;
    rejected as boolean;
    solved as boolean;
    comment as field;
    rewards as u64;
    claimed as boolean;

record user:
    owner as address.private;
    amount as u64.private;


mapping reports:
	key left as field.public;
	value right as Report.public;


mapping salts:
	key left as field.public;
	value right as field.public;


mapping counter:
	key left as u8.public;
	value right as u128.public;


mapping settings:
	key left as u8.public;
	value right as u32.public;

function submit_report:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.private;
    input r3 as user.record;
    sub r3.amount r1 into r4;
    cast self.caller r4 into r5 as user.record;
    hash.bhp256 self.caller into r6 as field;    hash.bhp256 r6 into r7 as field;    add r2 r7 into r8;
    hash.bhp256 r8 into r9 as field;    output r5 as user.record;

    finalize r0 r1 r9 r2;

finalize submit_report:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as field.public;
    get.or_use counter[0u8] 0u128 into r4;
    add r4 1u128 into r5;
    set r5 into counter[0u8];
    set r3 into salts[r2];
    cast r2 r1 block.height r0 0u128 0u128 false false false 0field 0u64 false into r6 as Report;
    set r6 into reports[r2];


function vote_yes:
    input r0 as field.private;

    finalize r0;

finalize vote_yes:
    input r0 as field.public;
    get reports[r0] into r1;
    is.eq r1.accepted false into r2;
    is.eq r1.rejected false into r3;
    and r2 r3 into r4;
    assert.eq r4 true;
    get.or_use settings[0u8] 0u32 into r5;
    add r1.block_height r5 into r6;
    gte block.height r6 into r7;
    gt r1.vote_yes r1.vote_no into r8;
    ternary r8 true false into r9;
    ternary r8 false true into r10;
    ternary r7 r9 false into r11;
    ternary r7 r10 false into r12;
    add r1.vote_yes 1u128 into r13;
    cast r1.id r1.security_deposit r1.block_height r1.content r13 r1.vote_no r11 r12 r1.solved r1.comment r1.rewards r1.claimed into r14 as Report;
    set r14 into reports[r0];


function vote_no:
    input r0 as field.private;

    finalize r0;

finalize vote_no:
    input r0 as field.public;
    get reports[r0] into r1;
    is.eq r1.accepted false into r2;
    is.eq r1.rejected false into r3;
    and r2 r3 into r4;
    assert.eq r4 true;
    get.or_use settings[0u8] 0u32 into r5;
    add r1.block_height r5 into r6;
    gte block.height r6 into r7;
    gt r1.vote_yes r1.vote_no into r8;
    ternary r8 true false into r9;
    ternary r8 false true into r10;
    ternary r7 r9 false into r11;
    ternary r7 r10 false into r12;
    add r1.vote_no 1u128 into r13;
    cast r1.id r1.security_deposit r1.block_height r1.content r1.vote_yes r13 r11 r12 r1.solved r1.comment r1.rewards r1.claimed into r14 as Report;
    set r14 into reports[r0];


function respond:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;

    finalize r0 r1 r2 r3;

finalize respond:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;
    get reports[r0] into r4;
    is.eq r4.accepted true into r5;
    is.eq r4.rejected true into r6;
    or r5 r6 into r7;
    assert.eq r7 true;
    add r4.vote_no 1u128 into r8;
    cast r4.id r4.security_deposit r4.block_height r4.content r4.vote_yes r8 r4.accepted r4.rejected r3 r1 r2 r4.claimed into r9 as Report;
    set r9 into reports[r0];


function claim:
    input r0 as field.private;
    input r1 as field.private;
    input r2 as u64.private;
    input r3 as user.record;
    hash.bhp256 self.caller into r4 as field;    hash.bhp256 r4 into r5 as field;    add r1 r5 into r6;
    hash.bhp256 r6 into r7 as field;    assert.eq r7 r0;
    add r3.amount r2 into r8;
    cast self.caller r8 into r9 as user.record;
    output r9 as user.record;

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
    cast r2.id r2.security_deposit r2.block_height r2.content r2.vote_yes r2.vote_no r2.accepted r2.rejected r2.solved r2.comment r2.rewards true into r8 as Report;
    set r8 into reports[r0];
