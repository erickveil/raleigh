const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function getVersion() {
    const pubspec = fs.readFileSync('pubspec.yaml', 'utf8');
    const versionMatch = pubspec.match(/^version:\s*([\d.]+)/m);
    return versionMatch ? versionMatch[1] : '0.0.1';
}

function getVersionCode(version) {
    const parts = version.split('.');
    const major = parseInt(parts[0]) || 0;
    const minor = parseInt(parts[1]) || 0;
    const patch = parseInt(parts[2]) || 0;
    return major * 10000 + minor * 100 + patch;
}

function safeRemove(filePath) {
    if (fs.existsSync(filePath)) {
        fs.rmSync(filePath, { recursive: true, force: true });
    }
}

function cleanDeployArtifacts(dirPath, matcher) {
    if (!fs.existsSync(dirPath)) return;
    for (const name of fs.readdirSync(dirPath)) {
        if (matcher.test(name)) {
            safeRemove(path.join(dirPath, name));
        }
    }
}

// ─── Configurable values ────────────────────────────────────────────────────
// Change this to the directory of whichever keystore set you want to use.
// Each directory should have its own key.properties + .jks file.
const KEYSTORE_DIR = 'D:\\AndroidPlayStore\\Dummy';
// ────────────────────────────────────────────────────────────────────────────

const version = getVersion();
const versionCode = getVersionCode(version);
const deployDir = path.join('scripts', 'deploy');
const apkName = path.join(deployDir, `raleigh-v${version}.apk`);
const keyPropsSource = path.join(KEYSTORE_DIR, 'key.properties');
const targetKeyPath = path.join('android', 'key.properties');
const androidBuildRoot = path.join('build', 'app');

console.log(`Building Android APK v${version} (versionCode: ${versionCode})...`);

try {
    if (!fs.existsSync(deployDir)) {
        fs.mkdirSync(deployDir, { recursive: true });
    }

    cleanDeployArtifacts(deployDir, /^raleigh-v.*\.apk$/i);

    console.log('Regenerating Android launcher icons...');
    execSync('dart run flutter_launcher_icons', { stdio: 'inherit' });

    // Prevent stale Android packaging artifacts from reusing old launcher resources.
    if (fs.existsSync(androidBuildRoot)) {
        try {
            safeRemove(androidBuildRoot);
        } catch (cleanupError) {
            console.warn(`Warning: Could not clean ${androidBuildRoot}: ${cleanupError.message}`);
        }
    }

    // Ensure key.properties is in place for signing
    if (fs.existsSync(keyPropsSource)) {
        console.log(`Copying signing properties from ${keyPropsSource}...`);
        let content = fs.readFileSync(keyPropsSource, 'utf8');
        content = content.replace(/storeFile=(.*)/, (match, p1) => {
            return `storeFile=${p1.replace(/\\/g, '\\\\')}`;
        });
        fs.writeFileSync(targetKeyPath, content);
    } else {
        console.warn(`Warning: Signing key not found at ${keyPropsSource}. Build might not be signed.`);
    }

    const buildCommand = `flutter build apk --release --build-name=${version} --build-number=${versionCode}`;
    execSync(buildCommand, { stdio: 'inherit' });

    const sourceApk = path.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
    if (fs.existsSync(sourceApk)) {
        console.log(`Naming APK to ${apkName}...`);
        fs.copyFileSync(sourceApk, apkName);
        console.log(`Build complete: ${apkName}`);
    } else {
        console.error('Could not find output APK.');
    }

} catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
}
