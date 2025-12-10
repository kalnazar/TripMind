import { NextRequest, NextResponse } from "next/server";
import { v2 as cloudinary } from "cloudinary";
import { cookies } from "next/headers";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME!,
  api_key: process.env.CLOUDINARY_API_KEY!,
  api_secret: process.env.CLOUDINARY_API_SECRET!,
});

export const runtime = "nodejs";

export async function POST(req: NextRequest) {
  // require login
  const token = (await cookies()).get(process.env.JWT_COOKIE_NAME!)?.value;
  if (!token)
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const form = await req.formData();
  const file = form.get("file") as File | null;
  if (!file) return NextResponse.json({ error: "No file" }, { status: 400 });
  if (file.size > 5 * 1024 * 1024) {
    return NextResponse.json({ error: "Max size 5MB" }, { status: 413 });
  }

  const arrayBuffer = await file.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);

  // Upload (signed, using your preset & optional folder)
  const uploaded = await new Promise<any>((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        upload_preset: process.env.CLOUDINARY_PRESET, // ← your signed preset
        folder: process.env.CLOUDINARY_FOLDER || undefined,
        resource_type: "image",
        overwrite: true,
        transformation: [
          { width: 512, height: 512, crop: "fill", gravity: "face" },
          { fetch_format: "auto", quality: "auto" },
        ],
      },
      (err, res) => (err ? reject(err) : resolve(res))
    );
    stream.end(buffer);
  });

  const url: string = uploaded.secure_url;

  // save URL in your Spring backend
  const save = await fetch(
    `${process.env.NEXT_PUBLIC_API_BASE_URL}/api/users/me/avatar`,
    {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ avatarUrl: url }),
      cache: "no-store",
    }
  );

  if (!save.ok) {
    return NextResponse.json(
      { error: "Failed to persist avatar" },
      { status: 500 }
    );
  }

  return NextResponse.json({ url });
}
