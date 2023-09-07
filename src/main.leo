// The 'guarded_feedback' program.
program guarded_feedback.aleo {

    struct Report {
        block_height: u32,
        content: field,
        user_hash: field,
        vote_count: u128,
        vote_mean: u128,
        rejected: bool,
        solved: bool,
        comment: field,
        rewards: u64,
    }

    mapping reports: Report => field;

    record user {
        owner: address,
        microcredits: u64,
        secret_salt: field,
    }

    transition submit_report(
        public content: field,
        public security_deposit: u64,
        private secret_salt: field,
    ) -> user {
        let new: user = user {
            owner: self.caller,
            microcredits: security_deposit,
            secret_salt: secret_salt,
        };
        let hash: field = BHP256::hash_to_field(self.caller);
        let id: field = BHP256::hash_to_field(secret_salt.add(hash));
        return new then finalize(content, security_deposit, id);
    }
    finalize submit_report(public content: field,
    public security_depost: u64,
    public id: field,)
    {

    }

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}
