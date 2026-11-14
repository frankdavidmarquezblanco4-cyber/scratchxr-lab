import asyncio, os
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8123/galeria-xr.html"
SHOTS = "/home/ubuntu/upload/scratchxr/shots"

async def profile(page):
    await page.fill("#accessNickname", "Luna")
    await page.select_option("#accessGrade", "6")
    await page.check("#accessConsent")
    await page.click("#accessSubmit")
    await page.wait_for_timeout(700)

async def main():
    os.makedirs(SHOTS, exist_ok=True)
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path="/usr/bin/chromium", args=[
            "--use-gl=swiftshader", "--enable-unsafe-swiftshader", "--no-sandbox",
            "--use-fake-device-for-media-stream", "--use-fake-ui-for-media-stream",
        ])
        ctx = await browser.new_context(viewport={"width": 1440, "height": 1000})
        page = await ctx.new_page()
        errors = []
        page.on("pageerror", lambda e: errors.append(f"PAGEERROR: {e}"))
        page.on("console", lambda m: errors.append(f"CONSOLE {m.type}: {m.text}") if m.type == "error" else None)
        await page.goto(URL, wait_until="load")
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{SHOTS}/01-gate.png")
        await profile(page)
        await page.wait_for_timeout(600)
        await page.screenshot(path=f"{SHOTS}/02-gallery.png")
        # scroll to bottom to trigger lazy images
        await page.mouse.wheel(0, 900)
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{SHOTS}/02b-gallery-bottom.png")
        await page.evaluate("window.scrollTo(0,0)")
        await page.wait_for_timeout(300)
        await page.locator('[data-open="gato"]').first.click()
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{SHOTS}/03-detail.png")
        await page.click('[data-close-dialog="modelDialog"]')
        await page.wait_for_timeout(300)
        # AR
        await page.click("#tab-ar")
        await page.wait_for_timeout(2500)
        await page.screenshot(path=f"{SHOTS}/04-ar.png")
        await page.click("#arScreenBtn")
        await page.wait_for_timeout(300)
        await page.click("#arScreenStart")
        await page.wait_for_timeout(2500)
        await page.screenshot(path=f"{SHOTS}/04b-ar-screen.png")
        await page.click("#arScreenStop")
        # VR
        await page.click("#tab-vr")
        await page.wait_for_timeout(9000)
        print("vr pedestals:", await page.locator(".pedestal").count())
        await page.screenshot(path=f"{SHOTS}/05-vr.png")
        # Hands with fake camera
        await page.click("#tab-hands")
        await page.wait_for_timeout(800)
        await page.check("#handsConsent")
        await page.click("#handsStartBtn")
        for _ in range(15):
            await page.wait_for_timeout(1000)
            badge = await page.locator("#handsBadge").inner_text()
            if "activa" in badge:
                break
        print("hands badge:", await page.locator("#handsBadge").inner_text())
        print("hands notice:", await page.locator("#handsNotice").inner_text())
        print("fps:", await page.locator("#fpsNow").inner_text())
        await page.screenshot(path=f"{SHOTS}/06-hands.png")
        await page.click("#handsStopBtn")
        await page.wait_for_timeout(500)
        # Upload
        await page.click("#tab-upload")
        await page.wait_for_timeout(500)
        await page.set_input_files("#fileInput", "/home/ubuntu/upload/scratchxr/scratchxr-lab/assets/models/Duck.glb")
        await page.wait_for_timeout(2500)
        print("uploads:", await page.locator(".upload-item").count())
        print("thumb after capture:", await page.evaluate("window.SXR.uploads.map(u=>({name:u.name,thumb:!!u.thumb}))"))
        await page.screenshot(path=f"{SHOTS}/07-upload-dialog.png")
        if await page.locator("#modelDialog").get_attribute("open") is not None:
            await page.click('[data-close-dialog="modelDialog"]')
        await page.wait_for_timeout(800)
        await page.screenshot(path=f"{SHOTS}/08-upload-list.png")
        print("thumb stored:", await page.evaluate("window.SXR.uploads.map(u=>({name:u.name,thumb:!!u.thumb}))"))
        # reload
        await page.reload(wait_until="domcontentloaded", timeout=60000)
        await page.wait_for_timeout(2500)
        print("gate after reload:", await page.locator("#accessGate").is_visible())
        print("uploads after reload:", await page.locator(".upload-item").count())
        print("profile name:", await page.locator("#profileName").inner_text())
        await page.screenshot(path=f"{SHOTS}/09-reload.png")
        print("---- ERRORS ----")
        for e in errors[:40]:
            print(e)
        await ctx.close()

        # Mobile pass
        mctx = await browser.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=2, is_mobile=True, has_touch=True)
        mp = await mctx.new_page()
        await mp.goto(URL, wait_until="load")
        await mp.wait_for_timeout(1000)
        await mp.screenshot(path=f"{SHOTS}/10-mobile-gate.png")
        await profile(mp)
        await mp.wait_for_timeout(600)
        await mp.screenshot(path=f"{SHOTS}/11-mobile-gallery.png")
        await mp.click("#tab-ar")
        await mp.wait_for_timeout(1500)
        await mp.screenshot(path=f"{SHOTS}/12-mobile-ar.png")
        await mctx.close()
        await browser.close()

asyncio.run(main())
