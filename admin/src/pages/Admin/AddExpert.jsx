import React, { useContext, useState } from "react";
import { useNavigate } from "react-router-dom";
import { AdminContext } from "../../context/AdminContext";
import { toast } from "react-toastify";

const AddExpert = () => {
  const navigate = useNavigate();
  const { createExpert } = useContext(AdminContext);

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [avatarUrl, setAvatarUrl] = useState("");
  const [location, setLocation] = useState("");
  const [experienceYears, setExperienceYears] = useState("");
  const [pricePerHour, setPricePerHour] = useState("");
  const [languages, setLanguages] = useState("");
  const [bio, setBio] = useState("");
  const [timeZone, setTimeZone] = useState("");
  const [countryCode, setCountryCode] = useState("");
  const [isShown, setIsShown] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const onSubmitHandler = async (event) => {
    event.preventDefault();
    setIsSubmitting(true);

    try {
      await createExpert({
        name,
        email,
        password,
        avatarUrl: avatarUrl.trim() ? avatarUrl.trim() : null,
        location: location.trim() ? location.trim() : null,
        experienceYears:
          experienceYears === "" ? null : Number(experienceYears),
        pricePerHour: pricePerHour === "" ? null : Number(pricePerHour),
        languages: languages.trim() ? languages.trim() : null,
        bio: bio.trim() ? bio.trim() : null,
        timeZone: timeZone.trim() ? timeZone.trim() : null,
        countryCode: countryCode.trim() ? countryCode.trim().toUpperCase() : null,
        isShown,
      });
      setName("");
      setEmail("");
      setPassword("");
      setAvatarUrl("");
      setLocation("");
      setExperienceYears("");
      setPricePerHour("");
      setLanguages("");
      setBio("");
      setTimeZone("");
      setCountryCode("");
      setIsShown(false);
      navigate("/experts");
    } catch (error) {
      toast.error(
        error?.response?.data?.message || error.message || "Failed to add expert"
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={onSubmitHandler} className="m-5 w-full">
      <div className="flex flex-col gap-1">
        <h1 className="text-lg font-medium">Add Expert</h1>
        <p className="text-sm text-gray-500">
          Create a new expert account for TripMind.
        </p>
      </div>

      <div className="tm-card px-8 py-8 mt-6 w-full max-w-3xl">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5 text-gray-600">
          <div className="flex flex-col gap-1">
            <p>Full name</p>
            <input
              onChange={(e) => setName(e.target.value)}
              value={name}
              className="tm-input"
              type="text"
              placeholder="Expert name"
              required
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Email</p>
            <input
              onChange={(e) => setEmail(e.target.value)}
              value={email}
              className="tm-input"
              type="email"
              placeholder="Email"
              required
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Password</p>
            <input
              onChange={(e) => setPassword(e.target.value)}
              value={password}
              className="tm-input"
              type="password"
              placeholder="Temporary password"
              required
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Avatar URL (optional)</p>
            <input
              onChange={(e) => setAvatarUrl(e.target.value)}
              value={avatarUrl}
              className="tm-input"
              type="url"
              placeholder="https://"
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Location</p>
            <input
              onChange={(e) => setLocation(e.target.value)}
              value={location}
              className="tm-input"
              type="text"
              placeholder="City or country"
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Experience (years)</p>
            <input
              onChange={(e) => setExperienceYears(e.target.value)}
              value={experienceYears}
              className="tm-input"
              type="number"
              min="0"
              placeholder="0"
            />
          </div>

          <div className="flex flex-col gap-1">
            <p>Price per hour</p>
            <input
              onChange={(e) => setPricePerHour(e.target.value)}
              value={pricePerHour}
              className="tm-input"
              type="number"
              min="0"
              step="0.01"
              placeholder="0"
            />
          </div>

          <div className="flex flex-col gap-1 md:col-span-2">
            <p>Languages</p>
            <input
              onChange={(e) => setLanguages(e.target.value)}
              value={languages}
              className="tm-input"
              type="text"
              placeholder="English, Kazakh"
            />
          </div>

          <div className="flex flex-col gap-1 md:col-span-2">
            <p>Bio</p>
            <textarea
              onChange={(e) => setBio(e.target.value)}
              value={bio}
              className="tm-input min-h-[120px]"
              rows={4}
              placeholder="Short expert bio"
            />
          </div>

          <div className="flex flex-col gap-1 md:col-span-2">
            <p>Time zone (IANA)</p>
            <input
              onChange={(e) => setTimeZone(e.target.value)}
              value={timeZone}
              className="tm-input"
              type="text"
              placeholder="Asia/Almaty"
            />
          </div>

          <div className="flex flex-col gap-1 md:col-span-2">
            <p>Country code (ISO-2)</p>
            <input
              onChange={(e) => setCountryCode(e.target.value)}
              value={countryCode}
              className="tm-input"
              type="text"
              placeholder="KZ"
              maxLength={2}
            />
          </div>

          <label className="flex items-center gap-2 text-sm md:col-span-2">
            <input
              type="checkbox"
              checked={isShown}
              onChange={(e) => setIsShown(e.target.checked)}
              className="cursor-pointer"
            />
            Show this expert to users
          </label>
        </div>

        <button
          type="submit"
          disabled={isSubmitting}
          className="tm-button mt-6 px-10 py-3 disabled:opacity-60"
        >
          {isSubmitting ? "Creating..." : "Create Expert"}
        </button>
      </div>
    </form>
  );
};

export default AddExpert;
