"use client";

import { useState, FormEvent, ChangeEvent } from "react";

interface FormData {
  uid: string;
  displayName: string;
  phoneNumber: string;
  role: "caregiver" | "elderly";
  familyId: string;
  disease: string;
  profileImgUrl: string;
}

// ✅ 1. ย้าย Component ย่อยออกมาข้างนอก
interface InputFieldProps {
  label: string;
  name: keyof FormData;
  type?: string;
  placeholder?: string;
  required?: boolean;
  value: string;
  onChange: (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
}

const InputField = ({
  label,
  name,
  type = "text",
  placeholder,
  required = false,
  value,
  onChange,
}: InputFieldProps) => (
  <div className="flex flex-col gap-1">
    <label className="text-sm font-medium text-gray-700" htmlFor={name}>
      {label} {required && <span className="text-red-500">*</span>}
    </label>
    <input
      id={name}
      name={name}
      type={type}
      placeholder={placeholder}
      required={required}
      value={value} // ✅ รับค่าผ่าน props
      onChange={onChange} // ✅ รับฟังก์ชันผ่าน props
      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
    />
  </div>
);

export default function CreateUserPage() {
  const [form, setForm] = useState<FormData>({
    uid: "",
    displayName: "",
    phoneNumber: "",
    role: "caregiver",
    familyId: "",
    disease: "",
    profileImgUrl: "",
  });

  const [isLoading, setIsLoading] = useState(false);
  const [status, setStatus] = useState<{
    type: "success" | "error" | null;
    message: string;
  }>({
    type: null,
    message: "",
  });

  const handleChange = (
    e: ChangeEvent<HTMLInputElement | HTMLSelectElement>,
  ) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    if (status.type === "error") setStatus({ type: null, message: "" });
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setStatus({ type: null, message: "" });

    try {
      const res = await fetch("http://localhost:3000/api/dev/create-user", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(form),
      });
      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.message || "เกิดข้อผิดพลาดบางอย่าง");
      }

      setStatus({ type: "success", message: "สร้างผู้ใช้สำเร็จ!" });
    } catch (error: any) {
      setStatus({
        type: "error",
        message: error.message || "ไม่สามารถสร้างผู้ใช้ได้",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white w-full max-w-lg rounded-xl shadow-lg p-8">
        <h1 className="text-2xl font-bold text-gray-800 mb-6 text-center">
          สร้างผู้ใช้งานใหม่ (Dev)
        </h1>

        {status.message && (
          <div
            className={`mb-6 p-4 rounded-lg text-sm ${
              status.type === "success"
                ? "bg-green-100 text-green-700"
                : "bg-red-100 text-red-700"
            }`}
          >
            {status.message}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div className="space-y-4">
            {/* ✅ 2. ส่ง value และ onChange เข้าไปแทน */}
            <InputField
              label="User UID"
              name="uid"
              placeholder="เช่น user_12345"
              required
              value={form.uid}
              onChange={handleChange}
            />
            <InputField
              label="ชื่อแสดงผล"
              name="displayName"
              placeholder="เช่น สมชาย ใจดี"
              required
              value={form.displayName}
              onChange={handleChange}
            />
            <InputField
              label="เบอร์โทรศัพท์"
              name="phoneNumber"
              type="tel"
              placeholder="08xxxxxxxx"
              required
              value={form.phoneNumber}
              onChange={handleChange}
            />

            <div className="flex flex-col gap-1">
              <label
                className="text-sm font-medium text-gray-700"
                htmlFor="role"
              >
                บทบาท (Role)
              </label>
              <select
                id="role"
                name="role"
                value={form.role}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white"
              >
                <option value="caregiver">ผู้ดูแล (Caregiver)</option>
                <option value="elderly">ผู้สูงอายุ (Elderly)</option>
              </select>
            </div>
          </div>

          <hr className="border-gray-200 my-4" />

          <div className="space-y-4">
            <InputField
              label="URL รูปโปรไฟล์"
              name="profileImgUrl"
              placeholder="https://..."
              value={form.profileImgUrl}
              onChange={handleChange}
            />
            <InputField
              label="Family ID"
              name="familyId"
              placeholder="ระบุ ID ครอบครัว (ถ้ามี)"
              value={form.familyId}
              onChange={handleChange}
            />
            <InputField
              label="โรคประจำตัว"
              name="disease"
              placeholder="ระบุโรค (ถ้ามี)"
              value={form.disease}
              onChange={handleChange}
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className={`w-full py-3 px-4 rounded-lg text-white font-medium transition-all ${
              isLoading
                ? "bg-gray-400 cursor-not-allowed"
                : "bg-blue-600 hover:bg-blue-700 active:scale-[0.98]"
            }`}
          >
            {isLoading ? (
              <span className="flex items-center justify-center gap-2">
                <svg
                  className="animate-spin h-5 w-5 text-white"
                  viewBox="0 0 24 24"
                >
                  <circle
                    className="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    strokeWidth="4"
                  ></circle>
                  <path
                    className="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  ></path>
                </svg>
                กำลังบันทึก...
              </span>
            ) : (
              "สร้างผู้ใช้งาน"
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
