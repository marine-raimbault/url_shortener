# UrlShortener

A journey from "this looks easy" to "distributed systems are hard" - building a URL shortener that scales.

## The Challenge

I wanted to push myself beyond tutorials, so I asked Claude AI for a deceptively simple project. Here's what we landed on:

> **"Build a URL shortener"** - Sounds trivial, right? Now handle 10,000 requests per second without losing data. You'll hit distributed consensus, database sharding, cache invalidation, rate limiting, and URL collision handling. Bonus: make it work across multiple servers.

## The Journey Ahead

### Phase 1: The "Easy" Version 🌱
```elixir
# This will work for exactly 3 users
def shorten_url(long_url) do
  short_code = generate_random_string(6)
  :ets.insert(:urls, {short_code, long_url})
  short_code
end
```

### Phase 2: Reality Hits 💥
- Random strings start colliding
- ETS dies when server restarts  
- One slow database write blocks everything
- Memory usage explodes

### Phase 3: The Real Problems Emerge 🔥
- **Base62 encoding vs UUIDs** - How do you generate unique codes fast?
- **Database bottlenecks** - Postgres can't handle 10k writes/sec on one table
- **Cache coherence** - What happens when cache and DB disagree?
- **Race conditions** - Two requests generate the same short code simultaneously

### Phase 4: Distributed Nightmare 🌪️
- Node A generates code "abc123", Node B generates the same code 0.001 seconds later
- Cache is on Node A, request comes to Node B
- Database sharding - which shard gets which URL?
- Consensus - how do nodes agree on anything?

## The Learning Curve

- **Week 1:** "This is easy!"
- **Week 2:** "Why is everything breaking?"
- **Week 3:** "What is CAP theorem and why do I care?"
- **Week 4:** "I understand distributed systems now and I hate everything"

## Quick Start

```bash
# Get started
mix deps.get
iex -S mix

# Try the basic version
iex> UrlShortener.start()
iex> code = UrlShortener.shorten("https://google.com")
"xK9mP2"
iex> UrlShortener.expand(code)
{:ok, "https://google.com"}
```

## Current Status

- [ ] Phase 1: Basic ETS implementation
- [ ] Phase 2: Add persistence and collision handling
- [ ] Phase 3: Database optimization and caching
- [ ] Phase 4: Multi-node distribution
- [ ] Phase 5: Handle 10k req/sec (the holy grail)

## What I'm Learning

This isn't just about URL shortening - it's about:
- **Concurrency patterns** in Elixir/OTP
- **Distributed systems** challenges
- **Database scaling** strategies  
- **Cache invalidation** (one of the two hard problems in CS)
- **System design** at scale

## Philosophy

> Start with the naive version. Let it break. Fix it. Let it break again. Each failure teaches you something fundamental about distributed systems that no tutorial ever could.

Ready to hate yourself for a month while becoming actually good at Elixir? Let's go.

---

*This project is intentionally over-engineered for learning purposes. If you just need a URL shortener, use bit.ly.*
