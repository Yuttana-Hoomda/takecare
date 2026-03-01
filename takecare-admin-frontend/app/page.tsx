"use client";
import { useState, useCallback } from "react";

// ─── Types ────────────────────────────────────────────────────────────────────
type UserRole = "elderly" | "caregiver";
type NCDisease = "diabetes" | "hypertension" | "arthritis" | "dementia";

interface UserField {
  uid: string;
  email: string;
  password: string;
  displayName: string;
  phoneNumber: string;
  profileImgUrl: string;
  role: UserRole;
  familyId: string;
  disease: NCDisease[];
  // extra custom fields
  customFields: { key: string; value: string }[];
}

interface LogEntry {
  id: number;
  type: "success" | "error" | "info";
  message: string;
  time: string;
}

// ─── Firebase REST endpoints ───────────────────────────────────────────────────
// const API_BASE = "http://10.0.2.2:3000/api";
const API_BASE = "http://localhost:3000/api";

const FIREBASE_AUTH_URL =
  "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=";

// ─── Helpers ──────────────────────────────────────────────────────────────────
const defaultUser = (): UserField => ({
  uid: "",
  email: "",
  password: "123456",
  displayName: "",
  phoneNumber: "",
  profileImgUrl: "",
  role: "elderly",
  familyId: "",
  disease: [],
  customFields: [],
});

const now = () =>
  new Date().toLocaleTimeString("th-TH", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });

// ─── Main Component ────────────────────────────────────────────────────────────
export default function FirebaseSeedTool() {
  const [apiKey, setApiKey] = useState("");
  const [users, setUsers] = useState<UserField[]>([defaultUser()]);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<"users" | "logs">("users");
  const [expandedIdx, setExpandedIdx] = useState<number | null>(0);

  const log = useCallback((type: LogEntry["type"], message: string) => {
    setLogs((prev) => [
      { id: Date.now(), type, message, time: now() },
      ...prev,
    ]);
  }, []);

  // ── User CRUD ─────────────────────────────────────────────────────────────
  const addUser = () => {
    setUsers((prev) => [...prev, defaultUser()]);
    setExpandedIdx(users.length);
  };

  const removeUser = (idx: number) => {
    setUsers((prev) => prev.filter((_, i) => i !== idx));
    setExpandedIdx(null);
  };

  const updateUser = (idx: number, patch: Partial<UserField>) => {
    setUsers((prev) =>
      prev.map((u, i) => (i === idx ? { ...u, ...patch } : u)),
    );
  };

  const toggleDisease = (idx: number, d: NCDisease) => {
    const user = users[idx]!;
    const has = user.disease.includes(d);
    updateUser(idx, {
      disease: has ? user.disease.filter((x) => x !== d) : [...user.disease, d],
    });
  };

  const addCustomField = (idx: number) => {
    const user = users[idx]!;
    updateUser(idx, {
      customFields: [...user.customFields, { key: "", value: "" }],
    });
  };

  const updateCustomField = (
    userIdx: number,
    fieldIdx: number,
    patch: { key?: string; value?: string },
  ) => {
    const user = users[userIdx]!;
    updateUser(userIdx, {
      customFields: user.customFields.map((f, i) =>
        i === fieldIdx ? { ...f, ...patch } : f,
      ),
    });
  };

  const removeCustomField = (userIdx: number, fieldIdx: number) => {
    const user = users[userIdx]!;
    updateUser(userIdx, {
      customFields: user.customFields.filter((_, i) => i !== fieldIdx),
    });
  };

  // ── Duplicate preset ──────────────────────────────────────────────────────
  const duplicateUser = (idx: number) => {
    const copy = { ...users[idx]!, uid: "", email: "", displayName: "" };
    setUsers((prev) => [...prev, copy]);
    setExpandedIdx(users.length);
  };

  // ── Seed single user ──────────────────────────────────────────────────────
  const seedUser = async (user: UserField): Promise<boolean> => {
    if (!apiKey) {
      log("error", "กรุณาใส่ Firebase API Key ก่อน");
      return false;
    }
    if (!user.email || !user.password || !user.phoneNumber) {
      log(
        "error",
        `[${user.displayName || user.email}] email / password / phoneNumber จำเป็น`,
      );
      return false;
    }

    try {
      // 1. Create Firebase Auth account
      log("info", `[${user.displayName}] กำลังสร้าง Firebase Auth...`);
      const authRes = await fetch(`${FIREBASE_AUTH_URL}${apiKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: user.email,
          password: user.password,
          returnSecureToken: true,
        }),
      });
      const authData = await authRes.json();
      if (!authRes.ok)
        throw new Error(authData.error?.message ?? "Auth failed");

      const uid: string = authData.localId;
      const token: string = authData.idToken;
      log("success", `[${user.displayName}]   Auth สร้างสำเร็จ uid: ${uid}`);

      // 2. Build profile payload
      const phone = user.phoneNumber.startsWith("0")
        ? user.phoneNumber
        : `0${user.phoneNumber}`;

      const profilePayload: Record<string, unknown> = {
        uid,
        displayName: user.displayName,
        phoneNumber: phone,
        profileImgUrl: user.profileImgUrl || "",
        role: user.role,
        ...(user.familyId ? { familyId: user.familyId } : {}),
        ...(user.disease.length
          ? { disease: user.disease }
          : { disease: null }),
        ...Object.fromEntries(
          user.customFields
            .filter((f) => f.key.trim())
            .map((f) => [f.key.trim(), f.value]),
        ),
      };

      // 3. POST to /api/users/profile
      log("info", `[${user.displayName}] กำลัง save profile...`);
      const profRes = await fetch(`${API_BASE}/users/profile`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(profilePayload),
      });
      if (!profRes.ok) {
        const err = await profRes.json();
        throw new Error(err.message ?? "Profile save failed");
      }
      log(
        "success",
        `[${user.displayName}]   Profile บันทึกสำเร็จ (${user.role})`,
      );
      return true;
    } catch (err: any) {
      log("error", `[${user.displayName}] ❌ ${err.message}`);
      return false;
    }
  };

  // ── Seed all ──────────────────────────────────────────────────────────────
  const seedAll = async () => {
    setLoading(true);
    setActiveTab("logs");
    log("info", `─── เริ่ม seed ${users.length} user(s) ───`);
    let ok = 0;
    for (const u of users) {
      const result = await seedUser(u);
      if (result) ok++;
    }
    log(
      ok === users.length ? "success" : "error",
      `─── เสร็จ: ${ok}/${users.length} สำเร็จ ───`,
    );
    setLoading(false);
  };

  const seedSingle = async (idx: number) => {
    setLoading(true);
    setActiveTab("logs");
    await seedUser(users[idx]!);
    setLoading(false);
  };

  // ── Import JSON ───────────────────────────────────────────────────────────
  const importJSON = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      try {
        const parsed = JSON.parse(ev.target?.result as string);
        const arr = Array.isArray(parsed) ? parsed : [parsed];
        const mapped: UserField[] = arr.map((item: any) => ({
          ...defaultUser(),
          ...item,
          customFields: item.customFields ?? [],
          disease: item.disease ?? [],
        }));
        setUsers(mapped);
        log("info", `Import สำเร็จ: ${mapped.length} user(s)`);
      } catch {
        log("error", "JSON format ไม่ถูกต้อง");
      }
    };
    reader.readAsText(file);
    e.target.value = "";
  };

  const exportJSON = () => {
    const blob = new Blob([JSON.stringify(users, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "seed-users.json";
    a.click();
    URL.revokeObjectURL(url);
  };

  // ─── Render ───────────────────────────────────────────────────────────────
  const roleColor: Record<UserRole, string> = {
    elderly: "#e8734a",
    caregiver: "#4a9eca",
  };

  return (
    <div style={S.root}>
      {/* ── Header ─────────────────────────────────────────────────────────── */}
      <header style={S.header}>
        <div style={S.headerLeft}>
          <span style={S.logo}>🌳</span>
          <div>
            <h1 style={S.title}>TakeCare Seed Tool</h1>
            <p style={S.subtitle}>Firebase User Data Seeder</p>
          </div>
        </div>
        <div style={S.headerRight}>
          <div style={S.apiKeyWrap}>
            <label style={S.label}>Firebase Web API Key</label>
            <input
              style={S.apiInput}
              type="password"
              placeholder="AIzaSy..."
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
            />
          </div>
        </div>
      </header>

      {/* ── Tabs ───────────────────────────────────────────────────────────── */}
      <div style={S.tabBar}>
        {(["users", "logs"] as const).map((t) => (
          <button
            key={t}
            style={{ ...S.tab, ...(activeTab === t ? S.tabActive : {}) }}
            onClick={() => setActiveTab(t)}
          >
            {t === "users"
              ? `👤 Users (${users.length})`
              : `📋 Logs (${logs.length})`}
          </button>
        ))}
        <div style={{ flex: 1 }} />
        {/* toolbar */}
        <label style={S.toolBtn}>
          📥 Import JSON
          <input
            type="file"
            accept=".json"
            onChange={importJSON}
            style={{ display: "none" }}
          />
        </label>
        <button style={S.toolBtn} onClick={exportJSON}>
          📤 Export JSON
        </button>
        <button style={S.toolBtn} onClick={addUser}>
          ＋ Add User
        </button>
        <button
          style={{ ...S.seedAllBtn, opacity: loading ? 0.6 : 1 }}
          onClick={seedAll}
          disabled={loading}
        >
          {loading ? "⏳ กำลัง Seed..." : `🚀 Seed All (${users.length})`}
        </button>
      </div>

      {/* ── Users Tab ──────────────────────────────────────────────────────── */}
      {activeTab === "users" && (
        <div style={S.content}>
          {users.length === 0 && (
            <div style={S.empty}>
              ยังไม่มี user — กด <b>＋ Add User</b> เพื่อเริ่ม
            </div>
          )}
          {users.map((user, idx) => {
            const isOpen = expandedIdx === idx;
            return (
              <div key={idx} style={S.card}>
                {/* Card Header */}
                <div
                  style={{
                    ...S.cardHeader,
                    borderLeft: `4px solid ${roleColor[user.role]}`,
                  }}
                  onClick={() => setExpandedIdx(isOpen ? null : idx)}
                >
                  <div style={S.cardHeaderLeft}>
                    <span
                      style={{
                        ...S.roleBadge,
                        background: roleColor[user.role],
                      }}
                    >
                      {user.role === "elderly" ? "👴 Elder" : "🧑‍⚕️ Caregiver"}
                    </span>
                    <span style={S.cardName}>
                      {user.displayName || (
                        <i style={{ opacity: 0.4 }}>ยังไม่ได้ใส่ชื่อ</i>
                      )}
                    </span>
                    <span style={S.cardEmail}>{user.email || "—"}</span>
                  </div>
                  <div style={S.cardHeaderRight}>
                    <button
                      style={S.iconBtn}
                      title="Seed user นี้"
                      onClick={(e) => {
                        e.stopPropagation();
                        seedSingle(idx);
                      }}
                    >
                      🚀
                    </button>
                    <button
                      style={S.iconBtn}
                      title="Duplicate"
                      onClick={(e) => {
                        e.stopPropagation();
                        duplicateUser(idx);
                      }}
                    >
                      📋
                    </button>
                    <button
                      style={{ ...S.iconBtn, color: "#e05c5c" }}
                      title="ลบ"
                      onClick={(e) => {
                        e.stopPropagation();
                        removeUser(idx);
                      }}
                    >
                      🗑
                    </button>
                    <span style={S.chevron}>{isOpen ? "▲" : "▼"}</span>
                  </div>
                </div>

                {/* Card Body */}
                {isOpen && (
                  <div style={S.cardBody}>
                    {/* Role Selector */}
                    <div style={S.row}>
                      <div style={S.fieldGroup}>
                        <label style={S.label}>Role *</label>
                        <div style={S.roleToggle}>
                          {(["elderly", "caregiver"] as UserRole[]).map((r) => (
                            <button
                              key={r}
                              style={{
                                ...S.roleBtn,
                                background:
                                  user.role === r ? roleColor[r] : "#1e2433",
                                color: user.role === r ? "#fff" : "#8892a4",
                                border: `1px solid ${user.role === r ? roleColor[r] : "#2e3548"}`,
                              }}
                              onClick={() => updateUser(idx, { role: r })}
                            >
                              {r === "elderly" ? "👴 Elderly" : "🧑‍⚕️ Caregiver"}
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Core fields */}
                    <div style={S.grid2}>
                      <Field
                        label="Display Name *"
                        value={user.displayName}
                        placeholder="สมชาย ใจดี"
                        onChange={(v) => updateUser(idx, { displayName: v })}
                      />
                      <Field
                        label="Phone Number *"
                        value={user.phoneNumber}
                        placeholder="0812345678"
                        onChange={(v) => {
                          // เอาเฉพาะตัวเลข
                          const phoneOnly = v.replace(/\D/g, "");

                          // generate email อัตโนมัติ
                          const autoEmail = phoneOnly
                            ? `${phoneOnly}@takecare.com`
                            : "";

                          updateUser(idx, {
                            phoneNumber: phoneOnly,
                            // ถ้า email ยังว่าง หรือเป็นรูปแบบ auto เดิม ให้ทับได้
                            email:
                              !user.email ||
                              user.email.endsWith("@takecare.com")
                                ? autoEmail
                                : user.email,
                          });
                        }}
                      />
                      <Field
                        label="Email (Firebase Auth) *"
                        value={user.email}
                        placeholder="user@takecare.com"
                        onChange={(v) => updateUser(idx, { email: v })}
                      />
                      <Field
                        label="Password"
                        value={user.password}
                        placeholder="123456"
                        onChange={(v) => updateUser(idx, { password: v })}
                      />
                      <Field
                        label="Profile Image URL"
                        value={user.profileImgUrl}
                        placeholder="https://..."
                        onChange={(v) => updateUser(idx, { profileImgUrl: v })}
                      />
                      <Field
                        label="Family ID (optional)"
                        value={user.familyId}
                        placeholder="ปล่อยว่างถ้ายังไม่มี"
                        onChange={(v) => updateUser(idx, { familyId: v })}
                      />
                    </div>

                    {/* Disease (Elderly only) */}
                    {user.role === "elderly" && (
                      <div style={S.fieldGroup}>
                        <label style={S.label}>Disease</label>
                        <div style={S.checkRow}>
                          {(
                            [
                              ["diabetes", "🩺 Diabetes"],
                              ["hypertension", "❤️ Hypertension"],
                              ["arthritis", "🦴 Arthritis"],
                              ["dementia", "🧠 Dementia"],
                            ] as [NCDisease, string][]
                          ).map(([d, label]) => (
                            <label key={d} style={S.checkLabel}>
                              <input
                                type="checkbox"
                                checked={user.disease.includes(d)}
                                onChange={() => toggleDisease(idx, d)}
                                style={{ marginRight: 6 }}
                              />
                              {label}
                            </label>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Custom Fields */}
                    <div style={S.fieldGroup}>
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: 12,
                          marginBottom: 8,
                        }}
                      >
                        <label style={S.label}>Custom Fields</label>
                        <button
                          style={S.addFieldBtn}
                          onClick={() => addCustomField(idx)}
                        >
                          ＋ Add Field
                        </button>
                      </div>
                      {user.customFields.length === 0 && (
                        <p
                          style={{ color: "#555f73", fontSize: 13, margin: 0 }}
                        >
                          ยังไม่มี custom field — กด ＋ Add Field
                          เพื่อเพิ่มข้อมูลพิเศษ
                        </p>
                      )}
                      {user.customFields.map((cf, fi) => (
                        <div key={fi} style={S.customFieldRow}>
                          <input
                            style={{ ...S.input, flex: 1 }}
                            placeholder="key เช่น age, ward..."
                            value={cf.key}
                            onChange={(e) =>
                              updateCustomField(idx, fi, {
                                key: e.target.value,
                              })
                            }
                          />
                          <span style={{ color: "#555f73" }}>:</span>
                          <input
                            style={{ ...S.input, flex: 2 }}
                            placeholder="value"
                            value={cf.value}
                            onChange={(e) =>
                              updateCustomField(idx, fi, {
                                value: e.target.value,
                              })
                            }
                          />
                          <button
                            style={{ ...S.iconBtn, color: "#e05c5c" }}
                            onClick={() => removeCustomField(idx, fi)}
                          >
                            ×
                          </button>
                        </div>
                      ))}
                    </div>

                    {/* Preview payload */}
                    <details style={S.preview}>
                      <summary style={S.previewSummary}>
                        👁 Preview JSON payload
                      </summary>
                      <pre style={S.previewCode}>
                        {JSON.stringify(
                          {
                            uid: "(จาก Firebase Auth)",
                            displayName: user.displayName,
                            phoneNumber: user.phoneNumber,
                            profileImgUrl: user.profileImgUrl || "",
                            role: user.role,
                            ...(user.familyId
                              ? { familyId: user.familyId }
                              : {}),
                            ...(user.disease.length
                              ? { disease: user.disease }
                              : { disease: null }),
                            ...Object.fromEntries(
                              user.customFields
                                .filter((f) => f.key)
                                .map((f) => [f.key, f.value]),
                            ),
                          },
                          null,
                          2,
                        )}
                      </pre>
                    </details>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* ── Logs Tab ───────────────────────────────────────────────────────── */}
      {activeTab === "logs" && (
        <div style={S.content}>
          <div
            style={{
              display: "flex",
              justifyContent: "flex-end",
              marginBottom: 12,
            }}
          >
            <button style={S.toolBtn} onClick={() => setLogs([])}>
              🗑 Clear Logs
            </button>
          </div>
          {logs.length === 0 && (
            <div style={S.empty}>ยังไม่มี log — กด Seed เพื่อเริ่ม</div>
          )}
          {logs.map((entry) => (
            <div
              key={entry.id}
              style={{
                ...S.logEntry,
                borderLeft: `3px solid ${entry.type === "success" ? "#4caf86" : entry.type === "error" ? "#e05c5c" : "#4a9eca"}`,
              }}
            >
              <span
                style={{
                  ...S.logBadge,
                  background:
                    entry.type === "success"
                      ? "#1a3d2e"
                      : entry.type === "error"
                        ? "#3d1a1a"
                        : "#1a2d3d",
                  color:
                    entry.type === "success"
                      ? "#4caf86"
                      : entry.type === "error"
                        ? "#e05c5c"
                        : "#4a9eca",
                }}
              >
                {entry.type === "success"
                  ? " "
                  : entry.type === "error"
                    ? "❌"
                    : "ℹ️"}
              </span>
              <span style={S.logMsg}>{entry.message}</span>
              <span style={S.logTime}>{entry.time}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ─── Field Component ──────────────────────────────────────────────────────────
function Field({
  label,
  value,
  placeholder,
  onChange,
}: {
  label: string;
  value: string;
  placeholder?: string;
  onChange: (v: string) => void;
}) {
  return (
    <div style={S.fieldGroup}>
      <label style={S.label}>{label}</label>
      <input
        style={S.input}
        value={value}
        placeholder={placeholder}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}

// ─── Styles ────────────────────────────────────────────────────────────────────
const S: Record<string, React.CSSProperties> = {
  root: {
    minHeight: "100vh",
    background: "#0d1117",
    color: "#c9d1d9",
    fontFamily: "'IBM Plex Mono', 'Fira Code', monospace",
    fontSize: 13,
  },
  header: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "20px 28px 16px",
    borderBottom: "1px solid #1e2433",
    gap: 24,
    flexWrap: "wrap",
  },
  headerLeft: { display: "flex", alignItems: "center", gap: 14 },
  headerRight: { display: "flex", alignItems: "flex-end", gap: 12 },
  logo: { fontSize: 36 },
  title: {
    margin: 0,
    fontSize: 22,
    fontWeight: 700,
    color: "#e6edf3",
    letterSpacing: -0.5,
  },
  subtitle: { margin: "2px 0 0", color: "#555f73", fontSize: 12 },
  apiKeyWrap: {
    display: "flex",
    flexDirection: "column",
    gap: 4,
    minWidth: 280,
  },
  apiInput: {
    background: "#161b22",
    border: "1px solid #2e3548",
    borderRadius: 6,
    padding: "7px 12px",
    color: "#c9d1d9",
    fontSize: 13,
    fontFamily: "inherit",
    outline: "none",
    width: "100%",
  },
  tabBar: {
    display: "flex",
    alignItems: "center",
    gap: 4,
    padding: "10px 20px",
    borderBottom: "1px solid #1e2433",
    flexWrap: "wrap",
  },
  tab: {
    background: "transparent",
    border: "1px solid transparent",
    borderRadius: 6,
    padding: "7px 16px",
    color: "#555f73",
    cursor: "pointer",
    fontSize: 13,
    fontFamily: "inherit",
  },
  tabActive: {
    background: "#161b22",
    border: "1px solid #2e3548",
    color: "#e6edf3",
  },
  toolBtn: {
    background: "#161b22",
    border: "1px solid #2e3548",
    borderRadius: 6,
    padding: "7px 13px",
    color: "#8892a4",
    cursor: "pointer",
    fontSize: 12,
    fontFamily: "inherit",
  },
  seedAllBtn: {
    background: "#1a3d2e",
    border: "1px solid #4caf86",
    borderRadius: 6,
    padding: "7px 18px",
    color: "#4caf86",
    cursor: "pointer",
    fontSize: 13,
    fontFamily: "inherit",
    fontWeight: 600,
    transition: "opacity .15s",
  },
  content: {
    maxWidth: 900,
    margin: "0 auto",
    padding: "20px 20px 60px",
    display: "flex",
    flexDirection: "column",
    gap: 12,
  },
  empty: {
    textAlign: "center",
    color: "#555f73",
    padding: "60px 0",
    fontSize: 14,
  },
  card: {
    background: "#161b22",
    borderRadius: 10,
    border: "1px solid #1e2433",
    overflow: "hidden",
  },
  cardHeader: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "14px 16px",
    cursor: "pointer",
    userSelect: "none",
    gap: 12,
  },
  cardHeaderLeft: { display: "flex", alignItems: "center", gap: 10 },
  cardHeaderRight: { display: "flex", alignItems: "center", gap: 6 },
  roleBadge: {
    borderRadius: 4,
    padding: "2px 8px",
    fontSize: 11,
    fontWeight: 600,
    color: "#fff",
  },
  cardName: { fontSize: 14, color: "#e6edf3", fontWeight: 600 },
  cardEmail: { fontSize: 12, color: "#555f73" },
  chevron: { fontSize: 10, color: "#555f73", marginLeft: 4 },
  iconBtn: {
    background: "transparent",
    border: "none",
    cursor: "pointer",
    fontSize: 15,
    padding: "4px 6px",
    borderRadius: 4,
    color: "#8892a4",
  },
  cardBody: {
    padding: "0 20px 20px",
    display: "flex",
    flexDirection: "column",
    gap: 18,
    borderTop: "1px solid #1e2433",
  },
  row: { display: "flex", gap: 16, paddingTop: 16 },
  grid2: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: "12px 20px",
  },
  fieldGroup: { display: "flex", flexDirection: "column", gap: 5 },
  label: {
    fontSize: 11,
    color: "#555f73",
    textTransform: "uppercase",
    letterSpacing: 0.8,
  },
  input: {
    background: "#0d1117",
    border: "1px solid #2e3548",
    borderRadius: 6,
    padding: "8px 12px",
    color: "#c9d1d9",
    fontSize: 13,
    fontFamily: "inherit",
    outline: "none",
    width: "100%",
    boxSizing: "border-box",
  },
  roleToggle: { display: "flex", gap: 8 },
  roleBtn: {
    borderRadius: 6,
    padding: "8px 18px",
    cursor: "pointer",
    fontSize: 13,
    fontFamily: "inherit",
    fontWeight: 500,
    transition: "all .15s",
  },
  checkRow: { display: "flex", gap: 20, flexWrap: "wrap" },
  checkLabel: {
    display: "flex",
    alignItems: "center",
    cursor: "pointer",
    color: "#8892a4",
    fontSize: 13,
  },
  addFieldBtn: {
    background: "transparent",
    border: "1px dashed #2e3548",
    borderRadius: 4,
    padding: "3px 10px",
    color: "#555f73",
    cursor: "pointer",
    fontSize: 12,
    fontFamily: "inherit",
  },
  customFieldRow: {
    display: "flex",
    alignItems: "center",
    gap: 8,
    marginBottom: 6,
  },
  preview: { marginTop: 4 },
  previewSummary: {
    cursor: "pointer",
    color: "#555f73",
    fontSize: 12,
    marginBottom: 8,
    userSelect: "none",
  },
  previewCode: {
    background: "#0d1117",
    border: "1px solid #1e2433",
    borderRadius: 6,
    padding: 14,
    margin: 0,
    fontSize: 12,
    color: "#4caf86",
    overflowX: "auto",
  },
  logEntry: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    padding: "9px 14px",
    background: "#161b22",
    borderRadius: 6,
    marginBottom: 4,
  },
  logBadge: {
    borderRadius: 4,
    padding: "2px 7px",
    fontSize: 11,
    whiteSpace: "nowrap",
  },
  logMsg: { flex: 1, color: "#c9d1d9", fontSize: 13 },
  logTime: { color: "#555f73", fontSize: 11, whiteSpace: "nowrap" },
};
