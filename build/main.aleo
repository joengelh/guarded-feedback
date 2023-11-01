program guarded_feedback_0_0_3.aleo;

struct Settings:
    owned_by as address;

struct Report:
    id as field;
    counter as u128;
    block_height as u32;
    content as field;
    solved as boolean;
    comment as field;
    rewards as u64;
    claimed as boolean;

record token:
    owner as address.private;
    amount as u64.private;

record reported:
    owner as address.private;
    id as field.private;


mapping settings:
	key as u8.public;
	value as Settings.public;


mapping counter:
	key as u8.public;
	value as u128.public;


mapping reports:
	key as u128.public;
	value as Report.public;


mapping ids:
	key as field.public;
	value as u128.public;


mapping account:
	key as address.public;
	value as u64.public;

function initialize_contract:
    input r0 as address.public;
    async initialize_contract r0 into r1;
    output r1 as guarded_feedback_0_0_3.aleo/initialize_contract.future;

finalize initialize_contract:
    input r0 as address.public;
    cast r0 into r1 as Settings;
    set r1 into settings[0u8];


function transfer_ownership:
    input r0 as address.private;
    async transfer_ownership self.caller r0 into r1;
    output r1 as guarded_feedback_0_0_3.aleo/transfer_ownership.future;

finalize transfer_ownership:
    input r0 as address.public;
    input r1 as address.public;
    get settings[0u8] into r2;
    is.eq r2.owned_by r0 into r3;
    assert.eq r3 true;
    cast r1 into r4 as Settings;
    set r4 into settings[0u8];


function submit:
    input r0 as field.private;
    hash.bhp256 self.caller into r1 as field;
    hash.bhp256 r1 into r2 as field;
    add r0 r2 into r3;
    hash.bhp256 r3 into r4 as field;
    cast self.caller r4 into r5 as reported.record;
    async submit r0 r4 into r6;
    output r4 as field.private;
    output r5 as reported.record;
    output r6 as guarded_feedback_0_0_3.aleo/submit.future;

finalize submit:
    input r0 as field.public;
    input r1 as field.public;
    contains ids[r1] into r2;
    is.eq r2 false into r3;
    assert.eq r3 true;
    get.or_use counter[0u8] 0u128 into r4;
    add r4 1u128 into r5;
    set r5 into counter[0u8];
    cast r1 r5 block.height r0 false 0field 0u64 false into r6 as Report;
    set r6 into reports[r5];
    set r5 into ids[r1];


function respond:
    input r0 as u128.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;
    async respond r0 r1 r2 r3 self.caller into r4;
    output r4 as guarded_feedback_0_0_3.aleo/respond.future;

finalize respond:
    input r0 as u128.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as boolean.public;
    input r4 as address.public;
    get settings[0u8] into r5;
    is.eq r5.owned_by r4 into r6;
    assert.eq r6 true;
    get reports[r0] into r7;
    cast r7.id r7.counter r7.block_height r7.content r3 r1 r2 r7.claimed into r8 as Report;
    set r8 into reports[r7.counter];


function claim:
    input r0 as field.private;
    input r1 as u64.private;
    hash.bhp256 self.caller into r2 as field;
    hash.bhp256 r2 into r3 as field;
    add r0 r3 into r4;
    hash.bhp256 r4 into r5 as field;
    cast self.caller r1 into r6 as token.record;
    async claim r1 r5 into r7;
    output r6 as token.record;
    output r7 as guarded_feedback_0_0_3.aleo/claim.future;

finalize claim:
    input r0 as u64.public;
    input r1 as field.public;
    get ids[r1] into r2;
    get reports[r2] into r3;
    is.eq r3.claimed false into r4;
    assert.eq r4 true;
    is.eq r3.rewards r0 into r5;
    assert.eq r5 true;
    cast r3.id r3.counter r3.block_height r3.content r3.solved r3.comment r3.rewards true into r6 as Report;
    set r6 into reports[r3.counter];


function transfer_public:
    input r0 as address.public;
    input r1 as u64.public;
    async transfer_public self.caller r0 r1 into r2;
    output r2 as guarded_feedback_0_0_3.aleo/transfer_public.future;

finalize transfer_public:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get.or_use account[r0] 0u64 into r3;
    sub r3 r2 into r4;
    set r4 into account[r0];
    get.or_use account[r1] 0u64 into r5;
    add r5 r2 into r6;
    set r6 into account[r1];


function transfer_private:
    input r0 as token.record;
    input r1 as address.private;
    input r2 as u64.private;
    sub r0.amount r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    cast r1 r2 into r5 as token.record;
    output r4 as token.record;
    output r5 as token.record;


function transfer_private_to_public:
    input r0 as token.record;
    input r1 as address.public;
    input r2 as u64.public;
    sub r0.amount r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    async transfer_private_to_public r1 r2 into r5;
    output r4 as token.record;
    output r5 as guarded_feedback_0_0_3.aleo/transfer_private_to_public.future;

finalize transfer_private_to_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];


function transfer_public_to_private:
    input r0 as address.public;
    input r1 as u64.public;
    cast r0 r1 into r2 as token.record;
    async transfer_public_to_private self.caller r1 into r3;
    output r2 as token.record;
    output r3 as guarded_feedback_0_0_3.aleo/transfer_public_to_private.future;

finalize transfer_public_to_private:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    sub r2 r1 into r3;
    set r3 into account[r0];


function burn_public:
    input r0 as u64.public;
    async burn_public self.caller r0 into r1;
    output r1 as guarded_feedback_0_0_3.aleo/burn_public.future;

finalize burn_public:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    sub r2 r1 into r3;
    set r3 into account[r0];
