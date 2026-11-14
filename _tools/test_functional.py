import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8123/galeria-xr.html"
DUCK = "/home/ubuntu/upload/scratchxr/scratchxr-lab/assets/models/Duck.glb"
TXT = "/home/ubuntu/upload/scratchxr/scratchxr-lab/_tools/nota.txt"
SHOTS = "/home/ubuntu/upload/scratchxr/shots"
fails = []

def check(name, cond, extra=""):
    print(("PASS " if cond else "FAIL ") + name + ((" · " + str(extra)) if extra else ""))
    if not cond:
        fails.append(name)

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path="/usr/bin/chromium", args=[
            "--use-gl=swiftshader", "--enable-unsafe-swiftshader", "--no-sandbox",
            "--use-fake-device-for-media-stream", "--use-fake-ui-for-media-stream"])
        ctx = await browser.new_context(viewport={"width": 1440, "height": 1000})
        page = await ctx.new_page()
        errors = []
        page.on("pageerror", lambda e: errors.append(str(e)))
        await page.goto(URL, wait_until="load")
        await page.wait_for_timeout(1200)

        # Gate validation
        await page.click("#accessSubmit")
        await page.wait_for_timeout(200)
        check("gate pide apodo", "apodo" in (await page.locator("#accessMessage").inner_text()).lower())
        await page.fill("#accessNickname", "Luna")
        await page.select_option("#accessGrade", "6")
        await page.click("#accessSubmit")
        await page.wait_for_timeout(200)
        check("gate pide consentimiento", "casilla" in (await page.locator("#accessMessage").inner_text()).lower(), await page.locator("#accessMessage").inner_text())
        await page.check("#accessConsent")
        await page.click("#accessSubmit")
        await page.wait_for_timeout(800)
        check("gate cerrada", not await page.locator("#accessGate").is_visible())
        check("perfil visible", await page.locator("#profileChip").is_visible())
        check("nombre perfil", (await page.locator("#profileName").inner_text()) == "Luna")

        # Gallery filters
        check("6 modelos", await page.locator(".model-card").count() == 6)
        await page.locator('#categoryChips button', has_text="Mascotas").click()
        await page.wait_for_timeout(250)
        check("filtro mascotas = 3", await page.locator(".model-card").count() == 3, await page.locator(".model-card").count())
        await page.locator('#categoryChips button', has_text="Granja").click()
        await page.wait_for_timeout(250)
        check("filtro granja = 3", await page.locator(".model-card").count() == 3, await page.locator(".model-card").count())
        await page.locator('#categoryChips button', has_text="Todos").click()
        await page.fill("#searchInput", "gato")
        await page.wait_for_timeout(300)
        check("búsqueda gato = 1", await page.locator(".model-card").count() == 1, await page.locator(".model-card").count())
        await page.fill("#searchInput", "")
        await page.wait_for_timeout(250)

        # Favorites
        await page.locator('[data-fav="gato"]').click()
        await page.wait_for_timeout(300)
        check("favorito suma", (await page.locator("#statFav").inner_text()) == "1")
        await page.click("#showFavsBtn")
        await page.wait_for_timeout(300)
        check("solo favoritos = 1", await page.locator(".model-card").count() == 1)
        await page.click("#showFavsBtn")
        await page.wait_for_timeout(250)

        # Detail dialog
        await page.locator('[data-open="gato"]').click()
        await page.wait_for_timeout(1600)
        check("diálogo abierto", await page.locator("#modelDialog").get_attribute("open") is not None)
        check("título diálogo", (await page.locator("#dialogTitle").inner_text()) == "Gato Scratch")
        await page.click('[data-close-dialog="modelDialog"]')
        await page.wait_for_timeout(300)

        # AR
        await page.click("#tab-ar")
        await page.wait_for_timeout(1500)
        check("AR activa pestaña", await page.locator("#view-ar").is_visible())
        await page.locator('#arPicker [data-id="dog"]').click()
        await page.wait_for_timeout(800)
        check("AR cambia modelo", (await page.locator("#arModelName").inner_text()) == "Cachorro")
        await page.click("#arNextBtn")
        await page.wait_for_timeout(500)
        check("AR siguiente", (await page.locator("#arModelName").inner_text()) != "Cachorro")
        await page.click("#arScreenBtn")
        await page.wait_for_timeout(300)
        await page.click("#arScreenStart")
        await page.wait_for_timeout(1500)
        check("RA pantalla cámara", await page.evaluate("!!document.querySelector('#arScreenVideo').srcObject"))
        await page.click("#arScreenStop")
        await page.wait_for_timeout(300)
        check("RA pantalla se detiene", await page.locator("#arScreenStart").is_enabled())

        # VR
        await page.click("#tab-vr")
        await page.wait_for_timeout(9000)
        check("VR escena", await page.locator("#vrScene").count() == 1)
        check("VR 6 pedestales", await page.locator(".pedestal").count() == 6)
        await page.select_option("#vrStartModel", "horse")
        await page.wait_for_timeout(1200)
        check("VR ficha caballo", "Caballo" in (await page.locator("#vrInfoName").inner_text()), await page.locator("#vrInfoName").inner_text())
        await page.click("#vrEnterBtn")
        await page.wait_for_timeout(1500)
        await page.evaluate("document.fullscreenElement && document.exitFullscreen()")
        await page.wait_for_timeout(500)

        # Hands
        await page.click("#tab-hands")
        await page.wait_for_timeout(800)
        await page.check("#handsConsent")
        await page.click("#handsStartBtn")
        for _ in range(20):
            await page.wait_for_timeout(1000)
            if "activa" in (await page.locator("#handsBadge").inner_text()).lower():
                break
        check("manos cámara activa", "activa" in (await page.locator("#handsBadge").inner_text()).lower(), await page.locator("#handsBadge").inner_text())
        await page.click("#handsResetBtn")
        await page.click("#handsStopBtn")
        await page.wait_for_timeout(600)
        check("manos se detiene", "apagada" in (await page.locator("#handsBadge").inner_text()).lower(), await page.locator("#handsBadge").inner_text())

        # Upload invalid
        await page.click("#tab-upload")
        await page.wait_for_timeout(300)
        await page.set_input_files("#fileInput", TXT)
        await page.wait_for_timeout(700)
        check("rechaza no GLB", "GLB" in (await page.locator("#dropNote").inner_text()) or "glb" in (await page.locator("#dropNote").inner_text()).lower(), await page.locator("#dropNote").inner_text())
        # Upload valid
        await page.set_input_files("#fileInput", DUCK)
        await page.wait_for_timeout(2500)
        check("subida válida", await page.locator(".upload-item").count() == 1)
        for _ in range(10):
            if await page.evaluate("window.SXR.uploads.every(u=>!!u.thumb)"):
                break
            await page.wait_for_timeout(1000)
        check("miniatura subida", await page.evaluate("window.SXR.uploads.every(u=>!!u.thumb)"))
        check("diálogo tras subir", await page.locator("#modelDialog").get_attribute("open") is not None)
        await page.click('[data-close-dialog="modelDialog"]')
        await page.wait_for_timeout(500)
        check("contador pestaña", (await page.locator("#tabUploadCount").inner_text()) == "1")
        # VR with upload
        await page.click("#tab-vr")
        await page.wait_for_timeout(5000)
        check("VR 7 pedestales", await page.locator(".pedestal").count() == 7, await page.locator(".pedestal").count())
        # Reload persistence
        await page.reload(wait_until="domcontentloaded", timeout=60000)
        await page.wait_for_timeout(2500)
        check("sesión persiste", not await page.locator("#accessGate").is_visible())
        check("subida persiste", await page.locator(".upload-item").count() == 1)
        check("favorito persiste", (await page.locator("#statFav").inner_text()) == "1")
        # Help & licenses
        await page.click("#helpBtn")
        await page.wait_for_timeout(300)
        check("ayuda abre", await page.locator("#helpDialog").get_attribute("open") is not None)
        await page.click('[data-close-dialog="helpDialog"]')
        await page.click("#licensesBtn")
        await page.wait_for_timeout(300)
        check("licencias abre", await page.locator("#licensesDialog").get_attribute("open") is not None)
        await page.click('[data-close-dialog="licensesDialog"]')
        # Prefs
        await page.click("#fontUpBtn")
        await page.click("#contrastBtn")
        await page.wait_for_timeout(300)
        check("contraste activo", await page.evaluate("document.body.classList.contains('high-contrast')"))
        await page.click("#contrastBtn")
        await page.click("#fontDownBtn")
        # Deep link
        await page.goto(URL + "#hands", wait_until="domcontentloaded")
        await page.wait_for_timeout(1500)
        check("enlace #hands", await page.locator("#view-hands").is_visible())
        check("sin errores JS", len(errors) == 0, errors[:5])
        await ctx.close()
        await browser.close()

    print("FALLOS:", fails)
    raise SystemExit(1 if fails else 0)

asyncio.run(main())
