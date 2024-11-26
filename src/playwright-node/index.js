import playwright from 'playwright';
import dotenv from 'dotenv';

(async () => {
    // 解析命令行参数
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.error('Usage: node index.js <url>');
        process.exit(1);
    }

    // 加载环境变量
    let env_path = '';

    switch (process.env.NODE_ENV) {
        case 'dev':
            env_path = '.env.dev'
            break;
        case 'prod':
            env_path = '.env.prod'
            break;
        default:
            throw new Error('Unknown NODE_ENV: ' + process.env.NODE_ENV);
    }

    const {
        HEADLESS,
        PROXY_SERVER,
        LOGIN_ID,
        LOGIN_PASS
    } = dotenv.config({ path: env_path }).parsed;

    let browser = null;
    try {
        // 获取浏览器页面实例
        browser = await playwright.chromium.launch(
            {
                headless: HEADLESS == 'true' ? true : false,
                proxy: { server: PROXY_SERVER }
            });
        const context = await browser.newContext();
        const page = await context.newPage();

        console.log("url", args[0]);
        // 打开网页进行授权
        await page.goto(args[0], { waitUntil: 'networkidle' });
        await page.getByPlaceholder('ログイン').fill(LOGIN_ID);
        await page.getByPlaceholder('半角英数記号').fill(LOGIN_PASS);
        await page.getByRole('button', { name: 'ログイン', exact: true }).click();
        await page.getByLabel('利用規定に同意').check();
        await page.getByRole('button', { name: '許可' }).click();

        // 等待页面加载完成
        await page.waitForLoadState('networkidle');
        const url = page.url();

        // 返回code,state
        const searchParams = URL.parse(url).searchParams;
        const code = searchParams.get('code');
        const state = searchParams.get('state');
        // 用于elixir捕获标准输出
        console.log(code, state);
    } catch (error) {
        console.log("error", error);
        process.exit(1);
    } finally {
        // 关闭浏览器
        if (browser) {
            await browser.close();
        }
    }
})();
