-- Схема приложения: задачи, фоновые дела, активность (для напоминаний 2–3 дня без активности)
CREATE SCHEMA IF NOT EXISTS assistant;

CREATE TABLE IF NOT EXISTS assistant.background_items (
    id            BIGSERIAL PRIMARY KEY,
    telegram_id   BIGINT NOT NULL,
    title         TEXT NOT NULL,
    notes         TEXT,
    status        TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'done', 'cancelled')),
    last_touch_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assistant.calendar_items (
    id            BIGSERIAL PRIMARY KEY,
    telegram_id   BIGINT NOT NULL,
    title         TEXT NOT NULL,
    description   TEXT,
    starts_at     TIMESTAMPTZ NOT NULL,
    ends_at       TIMESTAMPTZ,
    yandex_event_id TEXT,
    status        TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'done', 'cancelled')),
    last_touch_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assistant.conversation_turns (
    id            BIGSERIAL PRIMARY KEY,
    telegram_id   BIGINT NOT NULL,
    role          TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content       TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bg_tg_status ON assistant.background_items (telegram_id, status);
CREATE INDEX IF NOT EXISTS idx_cal_tg_starts ON assistant.calendar_items (telegram_id, starts_at);
CREATE INDEX IF NOT EXISTS idx_conv_tg_created ON assistant.conversation_turns (telegram_id, created_at DESC);

COMMENT ON TABLE assistant.background_items IS 'Дела без конкретной даты';
COMMENT ON TABLE assistant.calendar_items IS 'События и задачи с датой/временем (синхронизация с Я.Календарём через n8n)';
COMMENT ON TABLE assistant.conversation_turns IS 'История для LLM (опционально, краткое окно)';
