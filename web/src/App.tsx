import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_BASE_URL = 'http://localhost:8000/api/v1';

interface Joke {
  setup?: string;
  punchline?: string;
  joke?: string;
  delivery?: string;
  type: string;
  category?: string;
  source: string;
}

const App: React.FC = () => {
  const [joke, setJoke] = useState<Joke | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [category, setCategory] = useState('General');
  const [favorites, setFavorites] = useState<Joke[]>([]);

  const categories = ['General', 'Programming', 'Knock-knock'];

  const fetchRandomJoke = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_BASE_URL}/jokes/random`);
      setJoke(response.data);
    } catch (err) {
      setError('Failed to fetch joke. Please try again.');
      console.error(err);
    }
    setLoading(false);
  };

  const fetchJokeByCategory = async (selectedCategory: string) => {
    setLoading(true);
    setError(null);
    setCategory(selectedCategory);
    try {
      const response = await axios.get(
        `${API_BASE_URL}/jokes/category/${selectedCategory}`
      );
      setJoke(response.data);
    } catch (err) {
      setError('Failed to fetch joke. Please try again.');
      console.error(err);
    }
    setLoading(false);
  };

  const addToFavorites = () => {
    if (joke && !favorites.some(fav => fav.setup === joke.setup)) {
      setFavorites([...favorites, joke]);
    }
  };

  const copyToClipboard = () => {
    if (joke) {
      const jokeText = `${joke.setup || joke.joke}\n\n${joke.punchline || joke.delivery}`;
      navigator.clipboard.writeText(jokeText);
      alert('Joke copied to clipboard!');
    }
  };

  useEffect(() => {
    fetchRandomJoke();
  }, []);

  return (
    <div className="container">
      <header className="header">
        <h1>🎭 Joke Generator</h1>
        <p>Get random jokes from external APIs</p>
      </header>

      <div className="categories">
        <h3>Select Category:</h3>
        <div className="category-buttons">
          {categories.map(cat => (
            <button
              key={cat}
              className={`category-btn ${category === cat ? 'active' : ''}`}
              onClick={() => fetchJokeByCategory(cat)}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      <div className="joke-container">
        {loading && <div className="loading">Loading...</div>}
        {error && <div className="error">{error}</div>}
        {joke && (
          <div className="joke-card">
            <div className="joke-setup">
              <strong>Setup:</strong>
              <p>{joke.setup || joke.joke}</p>
            </div>
            <div className="joke-punchline">
              <strong>Punchline:</strong>
              <p>{joke.punchline || joke.delivery}</p>
            </div>
            <div className="joke-meta">
              <small>Source: {joke.source}</small>
            </div>
          </div>
        )}
      </div>

      <div className="actions">
        <button className="btn btn-primary" onClick={fetchRandomJoke}>
          🔄 Get Random Joke
        </button>
        <button className="btn btn-secondary" onClick={addToFavorites}>
          ⭐ Add to Favorites
        </button>
        <button className="btn btn-tertiary" onClick={copyToClipboard}>
          📋 Copy Joke
        </button>
      </div>

      {favorites.length > 0 && (
        <div className="favorites">
          <h3>Favorites ({favorites.length})</h3>
          <div className="favorites-list">
            {favorites.map((fav, index) => (
              <div key={index} className="favorite-item">
                <p>{fav.setup || fav.joke}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
