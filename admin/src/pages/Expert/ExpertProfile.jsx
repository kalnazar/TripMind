import React, { useContext, useEffect, useState } from "react";
import { ExpertContext } from "../../context/ExpertContext";

const ExpertProfile = () => {
  const { eToken, profileData, getProfileData, updateProfile } =
    useContext(ExpertContext);
  const [isEdit, setIsEdit] = useState(false);
  const [form, setForm] = useState({
    location: "",
    languages: "",
    countryCode: "",
    timeZone: "",
    experienceYears: "",
    pricePerHour: "",
    bio: "",
  });

  useEffect(() => {
    if (eToken) {
      getProfileData();
    }
  }, [eToken]);

  useEffect(() => {
    if (profileData) {
      setForm({
        location: profileData.location || "",
        languages: profileData.languages || "",
        countryCode: profileData.countryCode || "",
        timeZone: profileData.timeZone || "",
        experienceYears:
          profileData.experienceYears != null
            ? String(profileData.experienceYears)
            : "",
        pricePerHour:
          profileData.pricePerHour != null
            ? String(profileData.pricePerHour)
            : "",
        bio: profileData.bio || "",
      });
    }
  }, [profileData]);

  if (!profileData) {
    return (
      <div className="m-5 w-full">
        <div className="tm-card p-6 text-sm text-gray-600">
          Loading profile...
        </div>
      </div>
    );
  }

  const initials = profileData?.name
    ? profileData.name
        .split(" ")
        .map((part) => part[0])
        .slice(0, 2)
        .join("")
        .toUpperCase()
    : "EX";

  return (
    <div className="m-5 w-full max-w-2xl">
      <div className="tm-card p-6 flex flex-col gap-6">
        <div className="flex items-center gap-4">
          {profileData.avatarUrl ? (
            <img
              src={profileData.avatarUrl}
              alt={profileData.name}
              className="w-16 h-16 rounded-full object-cover"
            />
          ) : (
            <div className="w-16 h-16 rounded-full bg-primary/10 text-primary flex items-center justify-center text-lg font-semibold">
              {initials}
            </div>
          )}
          <div>
            <p className="text-xl font-semibold text-gray-900">
              {profileData.name}
            </p>
            <p className="text-gray-500">{profileData.email}</p>
          </div>
        </div>

        <div className="border-t border-gray-200 pt-4 text-sm text-gray-600 space-y-3">
          {isEdit ? (
            <>
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Location</span>
                  <input
                    className="tm-input"
                    value={form.location}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, location: e.target.value }))
                    }
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Languages</span>
                  <input
                    className="tm-input"
                    value={form.languages}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, languages: e.target.value }))
                    }
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Country (ISO-2)</span>
                  <input
                    className="tm-input"
                    value={form.countryCode}
                    onChange={(e) =>
                      setForm((prev) => ({
                        ...prev,
                        countryCode: e.target.value,
                      }))
                    }
                    maxLength={2}
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Time zone</span>
                  <input
                    className="tm-input"
                    value={form.timeZone}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, timeZone: e.target.value }))
                    }
                    placeholder="Asia/Almaty"
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Experience (years)</span>
                  <input
                    type="number"
                    className="tm-input"
                    value={form.experienceYears}
                    min="0"
                    onChange={(e) =>
                      setForm((prev) => ({
                        ...prev,
                        experienceYears: e.target.value,
                      }))
                    }
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="text-gray-500">Price per hour</span>
                  <input
                    type="number"
                    className="tm-input"
                    value={form.pricePerHour}
                    min="0"
                    step="0.01"
                    onChange={(e) =>
                      setForm((prev) => ({
                        ...prev,
                        pricePerHour: e.target.value,
                      }))
                    }
                  />
                </label>
              </div>
              <label className="flex flex-col gap-1">
                <span className="text-gray-500">Bio</span>
                <textarea
                  className="tm-input min-h-[120px]"
                  rows={4}
                  value={form.bio}
                  onChange={(e) =>
                    setForm((prev) => ({ ...prev, bio: e.target.value }))
                  }
                />
              </label>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => {
                    updateProfile({
                      location: form.location.trim() || null,
                      languages: form.languages.trim() || null,
                      countryCode: form.countryCode.trim() || null,
                      timeZone: form.timeZone.trim() || null,
                      experienceYears:
                        form.experienceYears === ""
                          ? null
                          : Number(form.experienceYears),
                      pricePerHour:
                        form.pricePerHour === ""
                          ? null
                          : Number(form.pricePerHour),
                      bio: form.bio.trim() || null,
                    }).catch(() => {});
                    setIsEdit(false);
                  }}
                  className="tm-button rounded-full px-4 py-1 text-sm"
                >
                  Save
                </button>
                <button
                  onClick={() => setIsEdit(false)}
                  className="tm-chip px-4 py-1 text-sm"
                >
                  Cancel
                </button>
              </div>
            </>
          ) : (
            <>
              {profileData.location && (
                <p>
                  <span className="text-gray-500">Location:</span>{" "}
                  {profileData.location}
                </p>
              )}
              {profileData.languages && (
                <p>
                  <span className="text-gray-500">Languages:</span>{" "}
                  {profileData.languages}
                </p>
              )}
              {profileData.countryCode && (
                <p>
                  <span className="text-gray-500">Country:</span>{" "}
                  {profileData.countryCode}
                </p>
              )}
              {profileData.timeZone && (
                <p>
                  <span className="text-gray-500">Time zone:</span>{" "}
                  {profileData.timeZone}
                </p>
              )}
              {profileData.experienceYears != null && (
                <p>
                  <span className="text-gray-500">Experience:</span>{" "}
                  {profileData.experienceYears} yrs
                </p>
              )}
              {profileData.pricePerHour != null && (
                <p>
                  <span className="text-gray-500">Price per hour:</span> ${" "}
                  {profileData.pricePerHour}
                </p>
              )}
              {profileData.bio && (
                <p className="text-gray-500">{profileData.bio}</p>
              )}
              <p>
                <span className="text-gray-500">Visible:</span>{" "}
                {profileData.isShown ? "Yes" : "No"}
              </p>
              <button
                onClick={() => setIsEdit(true)}
                className="tm-button rounded-full px-4 py-1 text-sm"
              >
                Edit
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default ExpertProfile;
