/**
 * 扫描和翻译脚本
 *
 * 功能：扫描 dealFile 文件夹中的文件，检测硬编码的中文字符
 *       将中文翻译为英文简译，生成与 string.json 相同结构的 JSON 文件
 *
 * 使用方法：
 *   在终端中执行：node scan-and-translate.js
 *
 * 要求：
 *   - 需要 Node.js 环境（无需安装任何额外依赖）
 *   - dealFile 文件夹需要存在
 *
 * 输出：
 *   - 生成的 JSON 文件保存在 resource/translated-strings.json
 */

const fs = require('fs');
const path = require('path');

// 配置路径
const DEAL_FILE_DIR = path.join(__dirname, 'dealFile');
const RESOURCE_DIR = path.join(__dirname, 'resource');
const OUTPUT_FILE = path.join(RESOURCE_DIR, 'translated-strings.json');

// 中文字符正则表达式（匹配中文字符）
const CHINESE_CHAR_REGEX = /[\u4e00-\u9fa5]+/g;

// 中英文词汇映射表（优先使用英文翻译）
const ENGLISH_MAP = {
    // 常用词汇
    '婴儿': 'baby', '名字': 'name', '标题': 'title', '列表': 'list',
    '流行': 'popular', '名人': 'famous', '城市': 'city',
    '菜单': 'menu', '项': 'item', '产品': 'product', '中心': 'center',
    '首页': 'home', '页': 'page', '关于': 'about', '我们': 'us',
    '联系': 'contact', '新闻': 'news', '动态': 'dynamic',
    '服务': 'service', '支持': 'support',
    // 产品相关
    '苹果': 'apple', '手机': 'phone', '华为': 'huawei', '平板': 'tablet',
    '小米': 'xiaomi', '电视': 'tv', '联想': 'lenovo', '电脑': 'computer',
    '戴尔': 'dell', '笔记本': 'laptop', '三星': 'samsung', '显示器': 'monitor',
    // 城市名称（常用城市名称的标准英文）
    '北京': 'beijing', '上海': 'shanghai', '广州': 'guangzhou', '深圳': 'shenzhen',
    '杭州': 'hangzhou', '成都': 'chengdu', '武汉': 'wuhan', '西安': 'xian',
    '南京': 'nanjing', '重庆': 'chongqing'
};

// 拼音映射表（作为备用方案，用于人名等专有名词）
const PINYIN_MAP = {
    // 常见姓氏
    '张': 'zhang', '李': 'li', '王': 'wang', '刘': 'liu', '陈': 'chen',
    '赵': 'zhao', '周': 'zhou', '吴': 'wu', '孙': 'sun',
    // 常见名字用字
    '磊': 'lei', '伟': 'wei', '平': 'ping', '雷': 'lei', '明': 'ming',
    '辉': 'hui', '军': 'jun', '莉': 'li', '娜': 'na', '四': 'si',
    '霞': 'xia', '洋': 'yang', '八': 'ba', '芳': 'fang', '五': 'wu',
    '敏': 'min', '三': 'san', '阳': 'yang', '六': 'liu', '九': 'jiu',
    '十': 'shi', '七': 'qi',
    // 单字翻译（用于组合词）
    '首': 'first', '关': 'about', '于': 'for', '我': 'me', '们': 's',
    '联': 'link', '系': 'relate', '产': 'product', '品': 'item',
    '中': 'center', '心': 'core', '新': 'new', '闻': 'news',
    '动': 'dynamic', '态': 'state', '服': 'service', '务': 'work',
    '支': 'support', '持': 'hold', '菜': 'menu', '单': 'list', '项': 'item'
};

/**
 * 将单个中文字符转换为英文（优先使用英文翻译，备用拼音）
 * @param {string} char - 中文字符
 * @returns {string} - 英文或拼音
 */
function charToEnglish(char) {
    // 优先查找英文映射，如果没有则使用拼音
    if (ENGLISH_MAP[char]) {
        return ENGLISH_MAP[char];
    }
    if (PINYIN_MAP[char]) {
        return PINYIN_MAP[char];
    }
    return null;
}

/**
 * 将中文文本转换为英文简译（优先使用英文翻译）
 * @param {string} chineseText - 中文文本
 * @returns {string} - 英文简译
 */
function translateToEnglish(chineseText) {
    if (!chineseText || typeof chineseText !== 'string') {
        return '';
    }

    // 特殊完整词汇映射（优先匹配完整词组）
    const specialMappings = {
        '婴儿名字': 'baby_names_title',
        '名字列表': 'name_list_title',
        '流行名字': 'popular_names_title',
        '名人名字': 'famous_names_title',
        '城市列表': 'city_list_title',
        '产品列表': 'product_list_title',
        '菜单项': 'menu_items_title',
        '首页': 'home_page',
        '关于我们': 'about_us',
        '联系我们': 'contact_us',
        '产品中心': 'product_center',
        '新闻动态': 'news',
        '服务支持': 'service_support'
    };

    // 检查是否有完整词汇的英文映射
    if (specialMappings[chineseText]) {
        return specialMappings[chineseText];
    }

    // 检查是否有完整词汇的英文翻译
    if (ENGLISH_MAP[chineseText]) {
        return ENGLISH_MAP[chineseText];
    }

    // 如果是人名（2-3个字符），使用拼音格式（人名通常使用拼音）
    if (chineseText.length <= 3 && chineseText.length >= 2 && /^[\u4e00-\u9fa5]+$/.test(chineseText)) {
        const pinyinParts = [];
        let hasValidTranslation = false;

        for (let i = 0; i < chineseText.length; i++) {
            const char = chineseText[i];
            const translation = charToEnglish(char);

            if (translation) {
                pinyinParts.push(translation);
                hasValidTranslation = true;
            } else {
                // 如果找不到映射，使用拼音作为备用
                const charCode = char.charCodeAt(0);
                pinyinParts.push('u' + charCode.toString(16));
            }
        }

        if (hasValidTranslation || pinyinParts.length > 0) {
            // 生成 name_xxx_yyy 格式
            return 'name_' + pinyinParts.join('_');
        }
    }

    // 对于其他文本，尝试拆解并翻译
    // 使用贪心算法，优先匹配最长的词组
    let remainingText = chineseText;
    const translatedWords = [];
    let i = 0;

    while (i < remainingText.length) {
        let matched = false;

        // 尝试匹配词组（从长到短，最长4个字符）
        for (let len = Math.min(4, remainingText.length - i); len >= 2; len--) {
            const phrase = remainingText.substring(i, i + len);
            if (ENGLISH_MAP[phrase]) {
                translatedWords.push(ENGLISH_MAP[phrase]);
                i += len;
                matched = true;
                break;
            }
        }

        // 如果没有匹配到词组，尝试匹配单字
        if (!matched) {
            const char = remainingText[i];
            if (/[\u4e00-\u9fa5]/.test(char)) {
                const translation = charToEnglish(char);
                if (translation) {
                    translatedWords.push(translation);
                } else {
                    // 如果找不到映射，使用 Unicode 编码作为备用
                    const charCode = char.charCodeAt(0);
                    translatedWords.push('u' + charCode.toString(16));
                }
            } else if (char.trim()) {
                // 非中文字符直接使用
                translatedWords.push(char.toLowerCase());
            }
            i++;
        }
    }

    // 如果完全没有有效翻译，使用备用方案
    if (translatedWords.length === 0) {
        return 'text_' + chineseText.split('').map(c => {
            if (/[\u4e00-\u9fa5]/.test(c)) {
                return 'u' + c.charCodeAt(0).toString(16);
            }
            return c.toLowerCase();
        }).join('_');
    }

    return translatedWords.join('_');
}

/**
 * 从文件名生成 key 前缀
 * @param {string} filename - 文件名（不含扩展名）
 * @returns {string} - key 前缀
 */
function generateKeyPrefix(filename) {
    // 将文件名转换为小写，用下划线替换连字符和大写字母前的空格
    return filename
        .replace(/([A-Z])/g, '_$1')
        .toLowerCase()
        .replace(/^_/, '')
        .replace(/\./g, '_');
}

/**
 * 从文件中提取所有中文字符串（只提取字符串字面量中的中文，跳过注释）
 * @param {string} filePath - 文件路径
 * @param {string} filename - 文件名
 * @returns {Object} - 包含 {strings: Array, replacements: Array} 的对象
 */
function extractChineseStrings(filePath, filename) {
    const originalContent = fs.readFileSync(filePath, 'utf-8');
    let content = originalContent;
    const chineseStrings = [];
    const replacements = []; // 用于存储替换信息
    const seenStrings = new Map(); // 用于去重，key为中文，value为keyName

    // 生成 key 名称的函数
    function generateKeyName(chineseText) {
        // 如果已经生成过，直接返回
        if (seenStrings.has(chineseText)) {
            return seenStrings.get(chineseText);
        }

        const translation = translateToEnglish(chineseText);
        const keyPrefix = generateKeyPrefix(path.basename(filename, path.extname(filename)));
        let keyName = translation;

        // 如果翻译结果不是以 keyPrefix 开头，则添加前缀
        if (!keyName.startsWith(keyPrefix)) {
            // 如果翻译结果已经是 name_ 开头，直接使用
            if (keyName.startsWith('name_')) {
                keyName = keyName;
            } else {
                // 否则添加文件前缀
                keyName = `${keyPrefix}_${translation}`;
            }
        }

        // 处理重复的 key（添加序号）
        let finalKeyName = keyName;
        let counter = 1;
        while (Array.from(seenStrings.values()).includes(finalKeyName)) {
            finalKeyName = counter === 1 ? `${keyName}2` : `${keyName}${counter + 1}`;
            counter++;
        }

        seenStrings.set(chineseText, finalKeyName);
        return finalKeyName;
    }

    // 1. 先移除单行注释（// 开头的注释）
    content = content.replace(/\/\/.*$/gm, '');

    // 2. 移除多行注释（/* ... */）
    content = content.replace(/\/\*[\s\S]*?\*\//g, '');

    // 3. 提取字符串字面量中的中文（单引号、双引号、反引号）
    // 使用更精确的匹配，同时记录位置信息
    const quotePatterns = [
        { regex: /'([^']*)'/g, quote: "'" },  // 单引号
        { regex: /"([^"]*)"/g, quote: '"' },  // 双引号
        { regex: /`([^`]*)`/g, quote: '`' }   // 反引号
    ];

    quotePatterns.forEach(({ regex, quote }) => {
        let match;
        const textWithoutComments = content;

        // 重置正则表达式
        regex.lastIndex = 0;

        while ((match = regex.exec(textWithoutComments)) !== null) {
            const fullMatch = match[0]; // 包含引号的完整匹配
            const stringContent = match[1]; // 字符串内容

            // 检查是否包含中文字符
            if (CHINESE_CHAR_REGEX.test(stringContent)) {
                // 如果整个字符串都是中文，直接替换
                if (/^[\u4e00-\u9fa5]+$/.test(stringContent)) {
                    const keyName = generateKeyName(stringContent);
                    const replacement = `$r('app.string.${keyName}')`;

                    replacements.push({
                        original: fullMatch,
                        replacement: replacement,
                        chineseText: stringContent,
                        keyName: keyName
                    });

                    // 添加到字符串列表
                    if (!chineseStrings.some(item => item.value === stringContent)) {
                        chineseStrings.push({
                            name: keyName,
                            value: stringContent
                        });
                    }
                } else {
                    // 如果字符串中混合了中文和其他字符，提取中文部分
                    const chineseMatches = stringContent.match(CHINESE_CHAR_REGEX);

                    if (chineseMatches) {
                        chineseMatches.forEach(chineseText => {
                            // 生成 key 名称
                            const keyName = generateKeyName(chineseText);

                            // 替换字符串中的中文部分
                            const newStringContent = stringContent.replace(
                                chineseText,
                                `\${$r('app.string.${keyName}')}`
                            );
                            const replacement = quote + newStringContent + quote;

                            replacements.push({
                                original: fullMatch,
                                replacement: replacement,
                                chineseText: chineseText,
                                keyName: keyName,
                                isPartial: true
                            });

                            // 添加到字符串列表
                            if (!chineseStrings.some(item => item.value === chineseText)) {
                                chineseStrings.push({
                                    name: keyName,
                                    value: chineseText
                                });
                            }
                        });
                    }
                }
            }
        }
    });

    return {
        strings: chineseStrings,
        replacements: replacements,
        filePath: filePath,
        originalContent: originalContent
    };
}

/**
 * 扫描 dealFile 文件夹中的所有文件
 * @returns {Object} - 包含 {allStrings: Array, fileData: Array} 的对象
 */
function scanDealFileFolder() {
    const allStrings = [];
    const fileDataList = []; // 存储每个文件的详细信息

    // 检查文件夹是否存在
    if (!fs.existsSync(DEAL_FILE_DIR)) {
        console.error(`错误：文件夹 ${DEAL_FILE_DIR} 不存在`);
        return { allStrings, fileDataList };
    }

    // 读取文件夹中的所有文件
    const files = fs.readdirSync(DEAL_FILE_DIR);

    console.log(`开始扫描文件夹: ${DEAL_FILE_DIR}`);
    console.log(`找到 ${files.length} 个文件\n`);

    // 遍历每个文件
    files.forEach(file => {
        const filePath = path.join(DEAL_FILE_DIR, file);
        const stats = fs.statSync(filePath);

        // 只处理文件（跳过文件夹）
        if (stats.isFile()) {
            console.log(`正在处理文件: ${file}`);

            try {
                const result = extractChineseStrings(filePath, file);

                if (result.strings.length > 0) {
                    console.log(`  找到 ${result.strings.length} 个中文字符串`);
                    allStrings.push(...result.strings);
                    fileDataList.push(result);
                } else {
                    console.log(`  未找到中文字符串`);
                }
            } catch (error) {
                console.error(`  处理文件 ${file} 时出错:`, error.message);
            }
        }
    });

    return { allStrings, fileDataList };
}

/**
 * 生成 JSON 文件
 * @param {Array} strings - 字符串数组
 */
function generateJsonFile(strings) {
    // 确保 resource 目录存在
    if (!fs.existsSync(RESOURCE_DIR)) {
        fs.mkdirSync(RESOURCE_DIR, { recursive: true });
        console.log(`创建目录: ${RESOURCE_DIR}`);
    }

    // 按照 name 字段排序
    strings.sort((a, b) => {
        if (a.name < b.name) return -1;
        if (a.name > b.name) return 1;
        return 0;
    });

    // 生成与 string.json 相同结构的 JSON 对象
    const jsonData = {
        string: strings
    };

    // 写入文件（格式化输出，2 个空格缩进）
    fs.writeFileSync(
        OUTPUT_FILE,
        JSON.stringify(jsonData, null, 2),
        'utf-8'
    );

    console.log(`\n生成 JSON 文件: ${OUTPUT_FILE}`);
    console.log(`共 ${strings.length} 个翻译条目`);
}

/**
 * 替换文件中的硬编码中文为资源引用
 * @param {Array} fileDataList - 文件数据列表
 */
function replaceChineseInFiles(fileDataList) {
    console.log(`\n开始替换文件中的硬编码中文...`);

    fileDataList.forEach(fileData => {
        const { filePath, originalContent, replacements } = fileData;
        let newContent = originalContent;
        let replacedCount = 0;

        if (replacements.length === 0) {
            return;
        }

        // 按原始字符串长度从长到短排序，避免替换冲突
        replacements.sort((a, b) => b.original.length - a.original.length);

        // 构建替换映射：同一个中文文本只对应一个keyName
        const replacementMap = new Map(); // key: 原始字符串, value: 替换字符串

        replacements.forEach(replacement => {
            // 如果同一个原始字符串已经有映射，使用已有的映射
            if (!replacementMap.has(replacement.original)) {
                replacementMap.set(replacement.original, replacement.replacement);
            }
        });

        // 执行替换（按长度从长到短，避免嵌套替换问题）
        const sortedReplacements = Array.from(replacementMap.entries()).sort(
            (a, b) => b[0].length - a[0].length
        );

        sortedReplacements.forEach(([original, replacement]) => {
            // 使用正则表达式确保只替换完整匹配的字符串字面量
            const escapedOriginal = original.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(escapedOriginal, 'g');

            // 计算替换次数
            const matches = newContent.match(regex);
            if (matches) {
                replacedCount += matches.length;
                newContent = newContent.replace(regex, replacement);
            }
        });

        // 如果内容有变化，写入文件
        if (newContent !== originalContent) {
            fs.writeFileSync(filePath, newContent, 'utf-8');
            console.log(`  ✓ ${path.basename(filePath)}: 替换了 ${replacedCount} 处`);
        }
    });

    console.log(`完成文件替换`);
}

/**
 * 主函数
 */
function main() {
    console.log('=== 开始扫描和翻译 ===\n');

    // 1. 扫描 dealFile 文件夹
    const { allStrings, fileDataList } = scanDealFileFolder();

    if (allStrings.length === 0) {
        console.log('\n未找到任何中文字符串，程序退出');
        return;
    }

    console.log(`\n总共找到 ${allStrings.length} 个中文字符串\n`);

    // 2. 生成 JSON 文件
    generateJsonFile(allStrings);

    // 3. 替换文件中的硬编码中文
    replaceChineseInFiles(fileDataList);

    console.log('\n=== 完成 ===');
}

// 运行主函数
if (require.main === module) {
    main();
}

module.exports = {
    extractChineseStrings,
    translateToEnglish,
    scanDealFileFolder,
    generateJsonFile
};

