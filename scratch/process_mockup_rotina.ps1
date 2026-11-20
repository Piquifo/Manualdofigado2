$code = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;

public class ImageProcessor {
    public static void ProcessImage(string srcPath, string destPath, int threshold, int featherRange) {
        using (Bitmap src = new Bitmap(srcPath)) {
            int w = src.Width;
            int h = src.Height;
            Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb);
            
            BitmapData srcData = src.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData destData = dest.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            
            int totalBytes = Math.Abs(srcData.Stride) * h;
            byte[] srcBytes = new byte[totalBytes];
            byte[] destBytes = new byte[totalBytes];
            
            System.Runtime.InteropServices.Marshal.Copy(srcData.Scan0, srcBytes, 0, totalBytes);
            Array.Copy(srcBytes, destBytes, totalBytes);
            
            bool[] isBg = new bool[w * h];
            Queue<int> queue = new Queue<int>();
            
            int upperCutoff = threshold + featherRange;
            
            // Seed from all edges
            for (int x = 0; x < w; x++) {
                Seed(0, x, w, h, srcBytes, isBg, queue, threshold);
                Seed(h - 1, x, w, h, srcBytes, isBg, queue, threshold);
            }
            for (int y = 0; y < h; y++) {
                Seed(y, 0, w, h, srcBytes, isBg, queue, threshold);
                Seed(y, w - 1, w, h, srcBytes, isBg, queue, threshold);
            }
            
            int[] dx = { 0, 0, 1, -1 };
            int[] dy = { 1, -1, 0, 0 };
            
            while (queue.Count > 0) {
                int curr = queue.Dequeue();
                int cy = curr / w;
                int cx = curr % w;
                
                for (int i = 0; i < 4; i++) {
                    int ny = cy + dy[i];
                    int nx = cx + dx[i];
                    
                    if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                        int nIdx = ny * w + nx;
                        if (!isBg[nIdx]) {
                            int nByte = ny * srcData.Stride + nx * 4;
                            byte b = srcBytes[nByte];
                            byte g = srcBytes[nByte + 1];
                            byte r = srcBytes[nByte + 2];
                            
                            // Check darkness
                            int maxVal = Math.Max(r, Math.Max(g, b));
                            if (maxVal <= threshold) {
                                isBg[nIdx] = true;
                                queue.Enqueue(nIdx);
                            }
                        }
                    }
                }
            }
            
            // Apply transparency and feathering
            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    int idx = y * w + x;
                    int bIdx = y * destData.Stride + x * 4;
                    
                    if (isBg[idx]) {
                        destBytes[bIdx + 3] = 0; // Completely transparent
                    } else {
                        // Check if adjacent to background for edge smoothing
                        bool nearBg = false;
                        for (int i = 0; i < 4; i++) {
                            int ny = y + dy[i];
                            int nx = x + dx[i];
                            if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                                if (isBg[ny * w + nx]) {
                                    nearBg = true;
                                    break;
                                }
                            }
                        }
                        
                        if (nearBg) {
                            byte b = srcBytes[bIdx];
                            byte g = srcBytes[bIdx + 1];
                            byte r = srcBytes[bIdx + 2];
                            int maxVal = Math.Max(r, Math.Max(g, b));
                            if (maxVal < upperCutoff) {
                                double alphaFactor = (double)(maxVal - threshold) / featherRange;
                                if (alphaFactor < 0.1) alphaFactor = 0;
                                if (alphaFactor > 1.0) alphaFactor = 1.0;
                                destBytes[bIdx + 3] = (byte)(255 * alphaFactor);
                            }
                        }
                    }
                }
            }
            
            System.Runtime.InteropServices.Marshal.Copy(destBytes, 0, destData.Scan0, totalBytes);
            src.UnlockBits(srcData);
            dest.UnlockBits(destData);
            
            dest.Save(destPath, ImageFormat.Png);
        }
    }
    
    private static void Seed(int y, int x, int w, int h, byte[] bytes, bool[] isBg, Queue<int> queue, int threshold) {
        int idx = y * w + x;
        if (!isBg[idx]) {
            int bIdx = y * (w * 4) + x * 4;
            byte b = bytes[bIdx];
            byte g = bytes[bIdx + 1];
            byte r = bytes[bIdx + 2];
            int maxVal = Math.Max(r, Math.Max(g, b));
            if (maxVal <= threshold + 5) {
                isBg[idx] = true;
                queue.Enqueue(idx);
            }
        }
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies "System.Drawing"

$src = "C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795202020308_a07c6450.jpg"
$dest = "d:\SITE TRAFEGO DR\images\mockup-rotina.png"

Write-Output "Processing Rotina mockup..."
[ImageProcessor]::ProcessImage($src, $dest, 25, 20)
Write-Output "Finished processing Rotina mockup!"

Get-Item $dest | Select-Object Name, Length, LastWriteTime
