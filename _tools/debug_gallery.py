import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8123/galeria-xr.html"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path="/usr/bin/chromium", args=[
            "--use-gl=swiftshader", "--enable-unsafe-swiftshader", "--no-sandbox"])
        ctx = await browser.new_context(viewport={"width": 1280, "height": 900})
        page = await ctx.new_page()
        page.on("pageerror", lambda e: print("PAGEERROR:", e))
        page.on("console", lambda m: print("CONSOLE", m.type, m.text) if m.type in ("error", "warning") else None)
        await page.goto(URL, wait_until="load")
        await page.wait_for_timeout(1200)
        await page.fill("#accessNickname", "Luna")
        await page.select_option("#accessGrade", "6")
        await page.check("#accessConsent")
        await page.click("#accessSubmit")
        await page.wait_for_timeout(500)
        color = await page.eval_on_selector("#contrastBtn", "el => getComputedStyle(el).color")
        print("contrast color:", color)
        await page.click("#tab-upload")
        await page.wait_for_timeout(500)
        await page.set_input_files("#fileInput", "/home/ubuntu/upload/scratchxr/scratchxr-lab/assets/models/Duck.glb")
        for i in range(12):
            await page.wait_for_timeout(2000)
            status = await page.locator("#dropNote").inner_text()
            note = await page.locator("#uploadStatus").inner_text()
            rows = await page.locator(".upload-item").count()
            print(i, "drop:", status, "| note:", note, "| rows:", rows, "| dialog:", await page.locator("#modelDialog").get_attribute("open"))
            if rows:
                break
        print("uploads JS:", await page.evaluate("window.SXR.uploads.length"))
        print("db check:", await page.evaluate("""new Promise((res)=>{const r=indexedDB.open('sxrGallery');r.onsuccess=()=>{const d=r.result;const t=d.transaction('models');const g=t.objectStore('models').getAll();g.onsuccess=()=>res(g.result.map(x=>({id:x.id,name:x.name,size:x.size,thumb:!!x.thumb})));};r.onerror=()=>res('error');})"""))
        # reload without VR
        print("reloading...")
        try:
            await page.reload(wait_until="domcontentloaded", timeout=60000)
            print("reloaded domcontentloaded")
            await page.wait_for_timeout(2000)
            print("uploads after reload:", await page.locator(".upload-item").count())
        except Exception as e:
            print("RELOAD FAIL", type(e).__name__, e)
        await browser.close()

asyncio.run(main())
