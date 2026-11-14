import asyncio
from playwright.async_api import async_playwright

ROOT = "/home/ubuntu/upload/scratchxr/scratchxr-lab"
MODELS = [
    ("scratch-cat", "assets/models/scratch-cat.glb", "Gato", "30deg 70deg 106%"),
    ("dog", "assets/models/Puppy.glb", "Cachorro", "30deg 68deg auto"),
    ("rabbit", "assets/models/LowPolyRabbit.glb", "Conejo", "25deg 70deg auto"),
    ("chicken", "assets/models/LowPolyChicken.glb", "Gallina", "30deg 70deg auto"),
    ("cow", "assets/models/LowPolyCow.glb", "Vaca", "30deg 70deg auto"),
    ("horse", "assets/models/LowPolyHorse.glb", "Caballo", "30deg 70deg auto"),
]

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path="/usr/bin/chromium", args=["--use-gl=swiftshader", "--enable-unsafe-swiftshader", "--no-sandbox"])
        page = await browser.new_page(viewport={"width": 1000, "height": 750}, device_scale_factor=1.5)
        for key, src, name, orbit in MODELS:
            url = f"http://127.0.0.1:8123/_tools/poster.html?src=/{src}&name={name}&orbit={orbit}"
            await page.goto(url)
            try:
                await page.wait_for_function("window.__ready === true || window.__error", timeout=90000)
            except Exception as error:
                print("timeout", key, error)
            error = await page.evaluate("window.__error")
            if error:
                print("error", key, error)
                continue
            await page.wait_for_timeout(1200)
            await page.locator("#stage").screenshot(path=f"{ROOT}/assets/models/{key}.webp", type="webp", quality=86)
            print("ok", key)
        await browser.close()

asyncio.run(main())
