# Backend Setup Guide

This project uses **[Supabase](https://supabase.com/)** as its backend for authentication, database, and API access.  
To run the app locally, you’ll need a local Supabase instance up and running.

## 1. Prerequisites

Make sure you have the following installed on your system:

- **[Docker](https://www.docker.com/get-started/)**  
    Supabase uses Docker containers to run locally.
- **[Supabase CLI](https://supabase.com/docs/guides/cli)**  
    You can install it via Homebrew, npm, or manual download.

## 2. Run

Start local Supabase instance:

```bash
supabase start
```

And if you want to stop it:

```bash
supabase stop
```

## 3. Backend Changes

If you want to modify the backend, fork this repository, commit changes and invite **TODO**.

> ❗️ Important -
> We expect that any changes will be applied to the backend when we run supabase start.