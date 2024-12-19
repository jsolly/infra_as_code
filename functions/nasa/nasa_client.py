import requests
from typing import TypedDict, Optional


class NASAImageMetadata(TypedDict):
    title: str
    explanation: str
    date: str
    url: str
    media_type: str
    service_version: str
    hdurl: Optional[str]


class NASAClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.nasa.gov/planetary/apod"

    def get_image_of_the_day(self) -> NASAImageMetadata:
        """Fetch NASA's Astronomy Picture of the Day"""
        params = {"api_key": self.api_key}
        response = requests.get(self.base_url, params=params)
        response.raise_for_status()
        return response.json()

    def download_image(self, url: str) -> bytes:
        """Download an image from a URL"""
        response = requests.get(url)
        response.raise_for_status()
        return response.content
