from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import httpx
from typing import Optional

app = FastAPI(
    title="Joke Generator API",
    description="API for fetching and managing jokes",
    version="0.1.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# External API URLs
OFFICIAL_JOKE_API = "https://official-joke-api.appspot.com"
JOKE_API = "https://v2.jokeapi.dev/joke"

class JokeService:
    @staticmethod
    async def fetch_random_joke() -> dict:
        """Fetch a random joke from Official Joke API"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(f"{OFFICIAL_JOKE_API}/random_joke", timeout=10)
                response.raise_for_status()
                return response.json()
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error fetching joke: {str(e)}")
    
    @staticmethod
    async def fetch_joke_by_category(category: str) -> dict:
        """Fetch joke by category (General, Programming, Knock-knock)"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    f"{OFFICIAL_JOKE_API}/jokes/{category}/random",
                    timeout=10
                )
                response.raise_for_status()
                return response.json()
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error fetching joke: {str(e)}")
    
    @staticmethod
    async def fetch_random_joke_v2(
        category: str = "Any",
        blacklist: Optional[str] = None
    ) -> dict:
        """Fetch joke from JokeAPI with advanced options"""
        async with httpx.AsyncClient() as client:
            try:
                params = {}
                if blacklist:
                    params['blacklist'] = blacklist
                
                response = await client.get(
                    f"{JOKE_API}/{category}",
                    params=params,
                    timeout=10
                )
                response.raise_for_status()
                return response.json()
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error fetching joke: {str(e)}")
    
    @staticmethod
    async def fetch_multiple_jokes(count: int = 10) -> list:
        """Fetch multiple random jokes"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    f"{OFFICIAL_JOKE_API}/jokes/ten",
                    timeout=10
                )
                response.raise_for_status()
                return response.json()
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error fetching jokes: {str(e)}")

@app.get("/")
async def root():
    return {"message": "Welcome to Joke Generator API"}

@app.get("/api/v1/jokes/random")
async def get_random_joke():
    """Get a random joke"""
    joke = await JokeService.fetch_random_joke()
    return {
        "setup": joke.get("setup"),
        "punchline": joke.get("punchline"),
        "type": joke.get("type"),
        "id": joke.get("id"),
        "source": "official-joke-api"
    }

@app.get("/api/v1/jokes/category/{category}")
async def get_joke_by_category(category: str):
    """Get joke by category (General, Programming, Knock-knock)"""
    valid_categories = ["General", "Programming", "Knock-knock"]
    if category not in valid_categories:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid category. Valid options: {', '.join(valid_categories)}"
        )
    
    joke = await JokeService.fetch_joke_by_category(category)
    return {
        "setup": joke.get("setup"),
        "punchline": joke.get("punchline"),
        "type": joke.get("type"),
        "category": category,
        "id": joke.get("id"),
        "source": "official-joke-api"
    }

@app.get("/api/v1/jokes/advanced")
async def get_advanced_joke(
    category: str = "Any",
    blacklist: Optional[str] = None
):
    """Get joke from JokeAPI with advanced filtering
    
    Categories: General, Programming, Knock-knock, Misc
    Blacklist: nsfw, religious, political, racist, sexist, explicit
    """
    joke = await JokeService.fetch_random_joke_v2(category, blacklist)
    
    if joke.get("type") == "single":
        return {
            "joke": joke.get("joke"),
            "type": "single",
            "category": joke.get("category"),
            "id": joke.get("id"),
            "source": "jokeapi"
        }
    else:
        return {
            "setup": joke.get("setup"),
            "delivery": joke.get("delivery"),
            "type": "twopart",
            "category": joke.get("category"),
            "id": joke.get("id"),
            "source": "jokeapi"
        }

@app.get("/api/v1/jokes/multiple")
async def get_multiple_jokes(count: int = 10):
    """Get multiple random jokes"""
    if count > 100:
        raise HTTPException(status_code=400, detail="Max 100 jokes allowed per request")
    
    jokes = await JokeService.fetch_multiple_jokes(count)
    return {
        "jokes": jokes,
        "count": len(jokes),
        "source": "official-joke-api"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
