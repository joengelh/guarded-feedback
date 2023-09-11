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

    // This stores a public salt the user can chose for every address, to resist hashing collisions and brute forcing.
    mapping salts: field => address;

    record user {
        owner: address,
        microcredits: u64,
        secret_salt: field,
    }

    // The transition is most likely run on the clients computer
    // Key Stretching and a random salt will be used to resist hashmaps and collisions, aswell as brute forcing
    transition submit_report(
        public content: field,
        public security_deposit: u64,
        private random_salt: field,
    ) -> user {
        let new: user = user {
            owner: self.caller,
            microcredits: security_deposit,
            secret_salt: random_salt,
        };
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(random_salt.add(key_stretching));
        return new then finalize(content, security_deposit, id, random_salt);
    }
    finalize submit_report(public content: field,
    public security_depost: u64,
    public id: field,
    public random_salt: field,)
    {
        // store the random salt
        // create the user struct and map it to the id
        // store the security deposit with the owner of the contract
    }

}
